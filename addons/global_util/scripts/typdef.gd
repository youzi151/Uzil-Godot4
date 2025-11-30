extends RefCounted

## Typdef 類型定義
##
## 用來定義與解析不同物件間的差異
##

## 原因
enum Reason {
	OK,
	UNKNOWN_ERR,
	DEF_ERR,
	DEF_NOT_EXIST,
	VAR_NOT_EXIST,
	FUNC_NOT_EXIST,
	VAR_TYPE_NOT_MATCH,
	FUNC_ARG_COUNT_ERR,
}

## 類型比較報告
class TypReport :
	var is_match := true
	var err = Reason.OK
	func _init (_is_match: bool, _err) :
		self.is_match = _is_match
		self.err = _err
	func _to_string() -> String :
		return "<match:%s, err:%s>" % [self.is_match, self.err]

## 類型域
class TypScope :
	
	## 類型:定義
	var _typ_to_def := {}
	
	## 定義類別
	func define (typ_name: StringName, def_dict: Dictionary) :
		if self._typ_to_def.has(typ_name) :
			push_error("typ_name[%s] already defined")
			return
		self._typ_to_def[typ_name] = def_dict
	
	## 移除定義
	func undef (typ_name: StringName) :
		if self._typ_to_def.has(typ_name) :
			self._typ_to_def.erase(typ_name)
	
	## 取得定義
	func getdef (typ_name: StringName) :
		if not self._typ_to_def.has(typ_name) : return null
		return self._typ_to_def[typ_name]
	
	## 是否相符
	func mtch (_def, target) -> bool :
		var report := self.diff(_def, target, true)
		return report.is_match
	
	## 比較 類型與對象 並產出結果
	func diff (_def, target, is_skip_if_not_match := false) -> TypReport :
		var err : int = Reason.UNKNOWN_ERR
		
		match typeof(_def) :
			# dict(定義本身)
			TYPE_DICTIONARY :
				return self._diff(_def, target, true)
			# str(定義名稱)
			TYPE_STRING, TYPE_STRING_NAME :
				# 若存在該定義
				if self._typ_to_def.has(_def) : 
					return self._diff(self._typ_to_def[_def], target, true)
				# 否則 錯誤
				else :
					err = Reason.DEF_NOT_EXIST
			# 其他 則 錯誤
			_ :
				err = Reason.DEF_NOT_EXIST
		
		return TypReport.new(false, err)
	
	## 具體比較
	func _diff (def_dict: Dictionary, target, is_skip_if_not_match := false) -> TypReport :
		match typeof(target) :
			TYPE_DICTIONARY :
				return self._diff_dict(def_dict, target, is_skip_if_not_match)
			TYPE_OBJECT :
				return self._diff_obj(def_dict, target, is_skip_if_not_match)
			_:
				return TypReport.new(false, Reason.VAR_TYPE_NOT_MATCH)
	
	## 具體比較 字典
	##
	## 可比較字典內的各個key與val
	## val 可為 : int-類型比較 / Dictionary-嵌套比較 / string-查找定義後嵌套比較
	##
	func _diff_dict (def_dict: Dictionary, target_dict: Dictionary, is_skip_if_not_match := false) :
		
		# 錯誤與原因
		var err_to_reason := {}
		# 預設 相符
		var is_target_match := true
		# 回傳報告
		var report := TypReport.new(is_target_match, err_to_reason)
		
		# 每一個定義資料中的key
		for key in def_dict.keys() :
			# 若 不存在 則
			if not target_dict.has(key) :
				# 設置 錯誤與原因
				err_to_reason[key] = Reason.VAR_NOT_EXIST
				is_target_match = false
				if is_skip_if_not_match : break
				
				# 忽略此定義key
				continue
			
			# 該定義值的類型
			var def_val = def_dict[key]
			var def_val_typ : int = typeof(def_val)
			var sub_target = target_dict[key]
			
			# 依照 定義值 的類型
			match def_val_typ :
				# 若為 數值 表示 類型
				TYPE_INT, TYPE_FLOAT :
					var def_typ : int = def_val
					# 若有指定類型 且 目標的該欄位類型不符
					if def_typ != -1 and typeof(sub_target) != def_typ :
						# 設置 錯誤與原因
						err_to_reason[key] = Reason.VAR_TYPE_NOT_MATCH
						is_target_match = false
						if is_skip_if_not_match : break
					# 若 無指定(-1) 或 類型相同 則 通過
				
				# 字串 -> 現有定義
				TYPE_STRING, TYPE_STRING_NAME :
					# 遞迴進入比較
					var typ_name : String = def_val
					var sub_report : TypReport = self.diff(typ_name, sub_target)
					if not sub_report.is_match :
						err_to_reason[key] = sub_report.err
						is_target_match = false
						if is_skip_if_not_match : break
				
				# 字典 -> 定義
				TYPE_DICTIONARY :
					# 遞迴進入比較
					var sub_def : Dictionary = def_val
					var sub_report : TypReport = self._diff(sub_def, sub_target)
					if not sub_report.is_match :
						err_to_reason[key] = sub_report.err
						is_target_match = false
						if is_skip_if_not_match : break
				
		
		# 設置 是否相符
		report.is_match = is_target_match
		if is_target_match : report.err = Reason.OK
		
		return report

	## 具體比較 物件
	## 
	## 可比較 --var 變數 與 --func 方法
	## 
	func _diff_obj (def_dict: Dictionary, target_obj: Object, is_skip_if_not_match := false) :
		# 錯誤與原因
		var err_to_reason := {}
		# 預設 相符
		var is_target_match := true
		# 回傳報告
		var report := TypReport.new(is_target_match, err_to_reason)
		
		# 變數 (看 名稱, 類型)
		if def_dict.has("--var") :
			# 每個指定變數
			var var_list : Array = def_dict["--var"]
			for each in var_list :
				var var_name : StringName = &""
				var var_typ : int = -1
				
				match typeof(each) :
					# str(名稱)
					TYPE_STRING, TYPE_STRING_NAME :
						var_name = each
					# [str(名稱), int(類型)]
					TYPE_ARRAY :
						var_name = each[0]
						var_typ = each[1]
					_ :
						is_target_match = false
						if is_skip_if_not_match : break
				
				# 若目標沒有該變數
				if not var_name in target_obj :
					# 設置 錯誤與原因
					err_to_reason[var_name] = Reason.VAR_NOT_EXIST
					# 設為 不相符
					is_target_match = false
					if is_skip_if_not_match : break
				
				if var_typ >= 0 and var_typ != typeof(target_obj) :
					# 設置 錯誤與原因
					err_to_reason[var_name] = Reason.VAR_TYPE_NOT_MATCH
					# 設為 不相符
					is_target_match = false
					if is_skip_if_not_match : break
				
		# 若 不相符 且 在不相符時跳過 則 直接返回
		if not is_target_match and is_skip_if_not_match : return report
		
		# 方法 (看 名稱, 參數數量)
		if def_dict.has("--func") :
			# 每個指定的方法
			var func_list : Array = def_dict["--func"]
			for each in func_list :
				var func_name : StringName = &""
				var func_arg_count : int = -1
				
				match typeof(each) :
					# str(名稱)
					TYPE_STRING, TYPE_STRING_NAME :
						func_name = each
					# [str(名稱), int(參數數量)]
					TYPE_ARRAY :
						func_name = each[0]
						func_arg_count = each[1]
					_:
						is_target_match = false
				
				# 若 目標 沒有該方法
				if not target_obj.has_method(func_name) :
					# 設置 缺少的方法與原因
					err_to_reason[func_name] = Reason.FUNC_NOT_EXIST
					# 設為 不相符
					is_target_match = false
					if is_skip_if_not_match : break
				
				# 若 有指定參數數量 且 參數數量 不相符
				if func_arg_count >= 0 and func_arg_count != target_obj.get_method_argument_count(func_name) :
					# 設置 缺少的方法與原因
					err_to_reason[func_name] = Reason.FUNC_ARG_COUNT_ERR
					# 設為 不相符
					is_target_match = false
					if is_skip_if_not_match : break
				
		# 設置 是否相符
		report.is_match = is_target_match
		if is_target_match : report.err = Reason.OK
			
		
		return report

## 鍵:域
var _key_to_scope := {}

## 預設 域
var _default_scope : TypScope

## 初始化
func _init () :
	self._default_scope = self.scope(&"")

## 取得 域
func scope (_key: StringName) :
	var _scp : TypScope = null
	if not self._key_to_scope.has(_key) :
		_scp = TypScope.new()
		self._key_to_scope[_key] = _scp
	else :
		_scp = self._key_to_scope[_key]
	return _scp

## 定義類別
func define (typ_name: StringName, def_dict: Dictionary) :
	self._default_scope.define(typ_name, def_dict)
## 移除定義
func undef (typ_name: StringName) :
	self._default_scope.undef(typ_name)
## 取得定義
func getdef (typ_name: StringName) :
	return self._default_scope.getdef(typ_name)
## 是否相符
func mtch (_def, target) -> bool :
	return self._default_scope.mtch(_def, target)
## 比較 類型與對象 並產出結果
func diff (_def, target, is_skip_if_not_match := false) -> TypReport :
	return self._default_scope.diff(_def, target, is_skip_if_not_match)
