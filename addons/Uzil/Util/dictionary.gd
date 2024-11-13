
## Dictionary相關
##
## 處理 Dictionary 的 相關事務
## 

## 進階合併 方式
enum MergeMethod {
	KEEP,
	OVERRITE,
	ADD, ADD_FORCE,
	SUB,
	FORMAT,
}

## 進階合併 設定 [符號, 方式]
var merge_ex_cfgs : Array = [
	["|", MergeMethod.KEEP],
	["", MergeMethod.OVERRITE],
	["=", MergeMethod.OVERRITE],
	["-", MergeMethod.SUB],
	["+", MergeMethod.ADD],
	["#", MergeMethod.ADD_FORCE],
	["%", MergeMethod.FORMAT],
]

## 進階合併 方式順序
var merge_ex_method_order : Array = []
## 進階合併 符號對應方式
var merge_ex_symbol_to_method : Dictionary = {}

## 初始化
func _init () :
	self._merge_ex_init()

## 進階 合併
func merge_ex (dict: Dictionary, to_merge: Dictionary, opts: Dictionary = {}) :
	
	# 目標keys
	var target_keys : Array = []
	if opts.has("keys") :
		target_keys = opts["keys"]
	var target_keys_exist : bool = target_keys.size() > 0
	
	# 排除keys
	var without_keys : Array = []
	if opts.has("without_keys") :
		without_keys = opts["without_keys"]
	var without_keys_exist : bool = without_keys.size() > 0
	
	# 融合方式:keys
	var method_to_keys : Dictionary = {}
	for full_key : String in to_merge :
		var method : String = ""
		var key : String = full_key
		
		var is_regex : bool = false
		# 若 key 有效
		if full_key.length() > 0 : 
			# 試取出 首個符號 作為 融合方法
			var _method : String = full_key[0]
			if self.merge_ex_method_order.has(_method) :
				method = _method
				key = full_key.right(-1)
		
		# 是否 為 正則式
		if key.length() > 0 and key[0] == "\\" :
			is_regex = true
			#key = key.right(-1) # regex就不走目標排除檢查, 應該不需要再拆了
		
		# 若 非正則式 則 依照是否為目標或排除 來 忽略
		if not is_regex :
			if target_keys_exist :
				if not target_keys.has(key) : continue
			if without_keys_exist :
				if without_keys.has(key) : continue
		
		# 加入 該方法的keys
		if method_to_keys.has(method) :
			method_to_keys[method].push_back(full_key)
		else :
			method_to_keys[method] = [full_key]
	
	# 依照 方式順序 排入總共需要處理的keys
	var sorted_keys : Array = []
	for method in self.merge_ex_method_order :
		if not method_to_keys.has(method) : continue
		sorted_keys.append_array(method_to_keys[method])
	
	# 每個需要處理的key
	for key : String in sorted_keys :
		
		# 新值
		var val_new = to_merge[key]
		var val_new_typ : int = typeof(val_new)
		
		# 方式
		var method_default : int = self.merge_ex_symbol_to_method[""]
		var method : int = method_default
		
		# 若 鍵有內容
		if key.length() > 0 :
			# 試取符號
			var symbol : String = key[0]
			if self.merge_ex_symbol_to_method.has(symbol) :
				method = self.merge_ex_symbol_to_method[symbol]
				key = key.right(-1)
		
		# 是否 為 正則式
		var is_regex : bool = false
		if key.length() > 0 and key[0] == "\\" :
			is_regex = true
		
		# 符合的鍵
		var matches : Array = []
		# 若非 正則式 則
		if not is_regex :
			# 直接加入
			matches.push_back(key)
		# 若是 正則式 則
		else :
			var pattern : String = key.right(-1)
			var regex : RegEx = RegEx.new()
			regex.compile(pattern)
			# 搜尋 所有舊字典的鍵
			for old_key in dict.keys() :
				var _match : RegExMatch = regex.search(old_key)
				if _match == null : continue
				G.print(_match.get_string())
				if _match.get_string() != old_key : continue
				# 若 完全符合 則 加入 符合的鍵
				matches.push_back(old_key)
		
		# 每個符合的鍵
		for each_match in matches :
			# 依照方法 把 新值 融入 字典
			self._merge_ex_val_to_dict(dict, method, each_match, val_new, val_new_typ)

func _merge_ex_val_to_dict (dict: Dictionary, method: MergeMethod, key: String, val_new, val_new_typ: int) :
	# 舊值
	var val_old = null
	var val_old_exist : bool = dict.has(key)
	if val_old_exist : val_old = dict[key]
	
	# 依照 合併方式
	match method : 
		# 保持 或 新增
		MergeMethod.KEEP :
			if not val_old_exist :
				dict[key] = val_new
		# 覆寫
		MergeMethod.OVERRITE :
			dict[key] = val_new
		
		# 格式
		MergeMethod.FORMAT :
			if typeof(val_old) != TYPE_STRING : return
			match val_new_typ :
				TYPE_DICTIONARY :
					dict[key] = val_old.format(val_new)
				TYPE_ARRAY :
					dict[key] = val_old % val_new
		
		# 增添
		MergeMethod.ADD, MergeMethod.ADD_FORCE :
			# 若 舊值 存在
			if val_old_exist :
				# 若 類型不一致 則 無效並忽略
				if val_new_typ != typeof(val_old) : return
			
			# 依照 新值類型
			match val_new_typ :
				# 字串
				TYPE_STRING :
					dict[key] = val_old + val_new if val_old_exist else val_new
				# 數字
				TYPE_FLOAT, TYPE_INT :
					dict[key] = val_old + val_new if val_old_exist else val_new
				# 陣列
				TYPE_ARRAY :
					# 是否 忽略已存在
					var is_ignore_exist : bool = method == MergeMethod.ADD
					
					if val_old_exist :
						var val_old_arr : Array = val_old.duplicate()
						var val_new_arr : Array = val_new
					
						# 每個 新值 的 成員
						for each in val_new_arr :
							# 若 忽略既存 且 已包含在舊值中 則 忽略
							if is_ignore_exist and val_old_arr.has(each) : continue
							# 加入
							val_old_arr.push_back(each)
						
						dict[key] = val_old_arr
						
					else :
						dict[key] = val_new
				
				# 字典
				TYPE_DICTIONARY :
					var val_old_dict : Dictionary = val_old.duplicate() if val_old_exist else {}
					var val_new_dict : Dictionary = val_new
					self.merge_ex(val_old_dict, val_new_dict)
					dict[key] = val_old_dict
		
		# 減去
		MergeMethod.SUB :
			# 若 舊值 存在
			if val_old_exist :
				# 若為 減去null 則視為 移除該key
				if method == MergeMethod.SUB and val_new_typ == TYPE_NIL :
					dict.erase(key)
					return
				# 若 類型不一致 則 無效並忽略
				elif val_new_typ != typeof(val_old) :
					return
			
			# 依照 新值類型
			match val_new_typ :
				# 字串
				TYPE_STRING :
					dict[key] = val_old.replace(val_new, "%s")
				# 數字
				TYPE_FLOAT, TYPE_INT :
					dict[key] = val_old - val_new
				# 陣列
				TYPE_ARRAY :
					var val_old_arr : Array = val_old.duplicate()
					var val_new_arr : Array = val_new
					
					for each in val_new_arr :
						val_old_arr.erase(each)
					
					dict[key] = val_old_arr
					
				# 字典
				TYPE_DICTIONARY :
					var val_old_dict : Dictionary = val_old.duplicate()
					var val_new_dict : Dictionary = val_new
					for _key in val_new_dict :
						if val_old_dict.has(_key) :
							val_old_dict.erase(_key)
					dict[key] = val_old_dict

## 進階合併 初始化
func _merge_ex_init () :
	for each in self.merge_ex_cfgs :
		var symbol : String = each[0]
		var method : MergeMethod = each[1] 
		self.merge_ex_method_order.push_back(symbol)
		self.merge_ex_symbol_to_method[symbol] = method
	#G.print(self.merge_ex_method_order)
	#G.print(self.merge_ex_symbol_to_method)

func map (dict: Dictionary, fn: Callable) -> Dictionary :
	var result := {}
	for key in dict :
		var new_val = fn.call(key, dict[key])
		result[key] = new_val
	return result

func filter (dict: Dictionary, fn: Callable) -> Dictionary :
	var result := {}
	for key in dict :
		var val = dict[key]
		if fn.call(key, val) == true :
			result[key] = val
	return result

func filter_keys (dict: Dictionary, keys: Array) :
	var result := {}
	for key in keys :
		if not dict.has(key) : continue
		result[key] = dict[key]
	return result

func get_from_dicts (key: String, dicts: Array, default_res = null) :
	for each in dicts :
		if each.has(key) :
			return each[key]
	return default_res

func get_from_dict (key: String, dict: Dictionary, default_res = null) :
	if dict.has(key) : return dict[key]
	return default_res
