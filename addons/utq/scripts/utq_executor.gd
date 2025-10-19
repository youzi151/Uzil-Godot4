## UTQ Instance (Refactored)
## 
## UTQ 標籤查詢系統主控制器
## 負責協調各模組工作, 提供對外介面
##

# Variable ===================

var inst

# GDScript ===================

## 初始化
func _init (_inst) :
	self.inst = _inst

# Public =====================


## 主要搜尋入口函數
##
## 參數:search_str - 查詢字串, 支援運算子和括號
## 返回:查詢結果陣列
##
func search (search_str: String) -> Dictionary :
	var results := {}
	
	# 步驟1:解析查詢字串, 將字串分解為token並建立語法樹
	var parsed_tokens : Array = self.parse_search_str(search_str)
	# 步驟2:執行查詢並處理運算子（順序已通過括號遞迴和左結合性確定）
	results = self._execute_tokens(parsed_tokens)
	
	return results



## 解析查詢字串的主函數
##
## 將查詢字串轉換為結構化的解析結果
##
func parse_search_str(search_str: String) -> Array :
	# 步驟1:將字串分解為基本token（查詢詞、運算子、括號）
	var tokens : Array = self._tokenize_str(search_str)
	# 步驟2:將token解析為結構化的查詢項目
	var parsed : Array = self._parse_tokens(tokens)
	return parsed


# Private ====================

## 詞法分析器:將查詢字串分解為基本token
##
## 參數:search_str - 原始查詢字串
## 返回:token陣列, 每個token包含type和content
##
func _tokenize_str (search_str: String) -> Array :
	
	var tokens := []
	var token_start := 0
	var token_end := 0
		
	# 追蹤是否在引號內, 引號內的內容不進行運算子解析
	var in_quotes := false 
	
	# 逐字元處理查詢字串
	for idx in range(search_str.length()):
		var char = search_str[idx]
		
		var is_symbol : bool = false
		if char == "(" or char == ")":
			is_symbol = true
		elif char in self.inst.cfg.operators:
			is_symbol = true
		
		# 處理引號:切換引號狀態
		if char == '"' or char == "'":
			in_quotes = !in_quotes
			# 推進token結束位置
			token_end = idx + 1 
		
		# 在引號外遇到運算子或括號時, 分割token
		elif not in_quotes and is_symbol:
			
			# 保存當前累積的查詢詞
			var token_content = search_str.substr(token_start, token_end - token_start).strip_edges()
			if token_content != "":
				tokens.push_back(["s", token_content])
			
			# 添加運算子或括號token
			tokens.push_back(["o", char])
			
			# 重置token位置
			token_start = idx + 1
			token_end = idx + 1
		else:
			# 推進token結束位置
			token_end = idx + 1
	
	# 處理最後一個token（如果有的話）
	var token_content = search_str.substr(token_start, token_end - token_start).strip_edges()
	if token_content != "":
		tokens.push_back(["s", token_content])
	
	return tokens

## 語法分析器:將token陣列解析為結構化的查詢項目
##
## 參數:tokens - token陣列, start_idx - 開始解析的位置, is_bracket - 是否在括號內
## 返回:解析結果Array
##
func _parse_tokens (tokens: Array, start_idx: int = 0, is_bracket: bool = false) -> Array :
	var result := []
	var idx : int = start_idx
	var depth : int = 1 if is_bracket else 0
	
	# 當 還未輪完所有token 且 括號內時
	while idx < tokens.size() and (not is_bracket or depth > 0):
		var token : Array = tokens[idx]
		
		match token[0]:
			"o":
				var content : String = token[1]
				match content:
					"(":
						depth += 1
						# 從下一個token開始解析為 裡層結果[結果, 結束位置]
						var nested_result = self._parse_tokens(tokens, idx + 1, true)
						# 加入子結果(group token)
						result.push_back(nested_result[0])
						# 交由子結果判定結束位置, 並預先減去常規推進量
						idx = nested_result[1] - 1
					")":
						depth -= 1
					_:
						if content in self.inst.cfg.operators:
							result.push_back(token)
			"s":
				result.push_back(token)
			
		# 常規推進到下一個token
		idx += 1
	
	# 如果在括號內, 返回 [括號內結果, 結束位置]
	if is_bracket:
		# 取消 常規推進
		idx -= 1
		return [
			["g", result], # 括號內結果
			idx # 結束位置
		]
	else:
		# 括號外結果
		return result

## 執行查詢項目的核心函數
##
## 參數:tokens - 解析後的查詢項目陣列
## 返回:最終查詢結果陣列
##
func _execute_tokens (tokens: Array) -> Dictionary :
	var results := {}
	var current_operator := ""  # 當前運算子
	
	# 逐個處理查詢項目
	for i in range(tokens.size()):
		var token = tokens[i]
		
		match token[0] :
			
			"o":
				# 記錄當前運算子, 等待下一個操作數
				current_operator = token[1]
				continue
			
			"g":
				# 先完整執行括號內的內容
				var bracket_result = self._execute_tokens(token[1])
				if self.inst.is_debug : G.print("括號組執行結果: %s" % [bracket_result])
			
				# 立即與前面的結果進行運算（左結合性）
				if current_operator.is_empty() :
					results = bracket_result
				else :
					results = self._apply_operator(results, bracket_result, "", current_operator)
			
			"s":
				# 執行查詢
				# 立即與前面的結果進行運算（左結合性）
				if results.size() == 0 :
					results = self.inst.queryer.query(token[1])
				elif not current_operator.is_empty() :
					if current_operator == self.inst.cfg.operator_fallback :
						results = self._apply_operator(results, {}, token[1], current_operator)
					else :
						results = self._apply_operator(results, self.inst.queryer.query(token[1]), "", current_operator)
	
	return results

## 應用運算子到兩個結果集
##
## 參數:left_results - 左邊結果, right_results - 右邊結果, operator - 運算子
## 返回:運算後的結果陣列
##
func _apply_operator(left_results: Dictionary, right_results: Dictionary, right_str: String, operator: String) -> Dictionary :
	if self.inst.is_debug : G.print("執行運算: %s %s %s" % [left_results, operator, right_results if right_results.size() > 0 else right_str])
	
	# 後備運算子:如果左邊有結果則使用左邊, 否則使用右邊
	if operator == self.inst.cfg.operator_fallback :
		if left_results.size() > 0:
			if self.inst.is_debug : G.print("後備結果 (使用左邊): %s" % [left_results])
			return left_results
		else:
			if not right_str.is_empty() :
				right_results = self.inst.queryer.query(right_str) 
			if self.inst.is_debug : G.print("後備結果 (使用右邊): %s" % [right_results])
			return right_results
	# 聯集運算子:合併兩個結果集, 去除重複
	elif operator == self.inst.cfg.operator_union :
		var result = self._union(left_results, right_results)
		if self.inst.is_debug : G.print("聯集結果: %s" % [result])
		return result
	# 交集運算子:傳回兩個結果集中共同擁有的項目
	elif operator == self.inst.cfg.operator_intersection :
		var result = self._intersection(left_results, right_results)
		if self.inst.is_debug : G.print("交集結果: %s" % [result])
		return result
	# 對稱差運算子:傳回只存在於其中一個集合的項目
	elif operator == self.inst.cfg.operator_symmetric_difference :
		var result = self._symmetric_difference(left_results, right_results)
		if self.inst.is_debug : G.print("對稱差結果: %s" % [result])
		return result
	else :
		if self.inst.is_debug : G.print("未知運算子: %s" % [operator])
		return left_results


## 聯集 : 合併兩個結果集, 去除重複項目
##
## 參數: left左邊結果集, right右邊結果集
## 返回:合併後的結果集
##
func _union (left_results: Dictionary, right_results: Dictionary) -> Dictionary :
	var result := {}
	
	# 添加左邊的結果（保持原有順序）
	for item in left_results :
		result[item] = true
	
	# 添加右邊的結果（保持原有順序）
	for item in right_results :
		if not result.has(item) :
			result[item] = true
	
	return result

## 交集 : 傳回兩個結果集中共同擁有的項目
##
## 參數: left左邊結果集, right右邊結果集
## 返回: 交集後的結果集
##
func _intersection (left_results: Dictionary, right_results: Dictionary) -> Dictionary :
	var result := {}
	var is_left_less := left_results.size() <= right_results.size()
	var less : Dictionary = left_results if is_left_less else right_results
	var more : Dictionary = left_results if not is_left_less else right_results
	
	for each in less :
		if more.has(each) :
			result[each] = true
	
	return result

## 對稱差 : 傳回只存在於其中一個集合的項目
##
## 參數: left左邊結果集, right右邊結果集
## 返回: 對稱差後的結果集
##
func _symmetric_difference (left: Dictionary, right: Dictionary) -> Dictionary :
	var result := {}
	var seen := {}
	
	# 處理左側集合
	for item in left:
		seen[item] = true
		result[item] = true
	
	# 處理右側集合
	for item in right:
		if not seen.has(item):
			seen[item] = true
			result[item] = true
		else:
			# 如果項目已存在, 則從結果中移除（對稱差的定義）
			result.erase(item)
	
	return result
