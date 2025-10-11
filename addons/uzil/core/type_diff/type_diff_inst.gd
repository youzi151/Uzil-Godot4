extends RefCounted

## TypeDiff 類別差異 實體
##
## 用來定義與解析不同物件間的差異
##

enum Reason {
	VAR_NOT_EXIST,
	FUNC_NOT_EXIST,
	VAR_TYPE_NOT_MATCH,
	FUNC_ARG_COUNT_ERR,
}

# Variable ===================

## 類型:定義
var _typ_name_to_def := {}

# Extends ====================

# GDScript ===================

# Public =====================

## 定義類別
func set_def (typ_name: StringName, def_dict: Dictionary) :
	if self._typ_name_to_def.has(typ_name) :
		push_error("typ_name[%s] already defined")
		return
	self._typ_name_to_def[typ_name] = def_dict

## 移除定義
func del_def (typ_name: StringName) :
	if self._typ_name_to_def.has(typ_name) :
		self._typ_name_to_def.erase(typ_name)

## 取得定義
func get_def (typ_name: StringName) :
	if not self._typ_name_to_def.has(typ_name) : return null
	return self._typ_name_to_def[typ_name]

## 是否相符
func is_match (typ_name: StringName, target) -> bool :
	if not self._typ_name_to_def.has(typ_name) : return false
	var report := self.compare(typ_name, target, true)
	return report["is_match"]

## 比較並產出結果
func compare (typ_name: StringName, target, is_skip_if_not_match := false) -> Dictionary :
	
	# 錯誤與原因
	var err_to_reason := {}
	# 回傳報告
	var report := {
		"is_match": false,
		"error": err_to_reason
	}
	# 預設 相符
	var is_match := true
	
	# 若 沒有此類別的定義 則 返回報告
	if not self._typ_name_to_def.has(typ_name) : return report
	# 定義資料
	var def_dict : Dictionary = self._typ_name_to_def[typ_name]
	
	# 依照目標類型
	match typeof(target) :
		TYPE_DICTIONARY :
			var target_dict : Dictionary = target
			# 每一個定義資料中的key
			for key in def_dict.keys() :
				# 若 不存在 則
				if not target_dict.has(key) :
					# 設置 錯誤與原因
					err_to_reason[key] = Reason.VAR_NOT_EXIST
					is_match = false
					if is_skip_if_not_match : break
					
					# 忽略此定義key
					continue
				
				# 該定義欄位類型的類型
				var field_type = def_dict[key]
				# 依照 欄位類型 的類型
				match typeof(field_type) :
					# 整數 -> 類型
					TYPE_INT :
						# 若有指定類型 且 目標的該欄位類型不符
						if field_type != -1 and typeof(target_dict[key]) != field_type :
							# 設置 錯誤與原因
							err_to_reason[key] = Reason.VAR_TYPE_NOT_MATCH
							is_match = false
							if is_skip_if_not_match : break
					# 字串 -> 定義
					TYPE_STRING, TYPE_STRING_NAME :
						# 遞迴進入比較
						var sub_report : Dictionary = self.compare(field_type, target_dict[key])
						if not sub_report["is_match"] :
							err_to_reason[key] = sub_report["error"]
							is_match = false
							if is_skip_if_not_match : break
			
		TYPE_OBJECT :
			var target_obj : Object = target
			# 變數
			if def_dict.has("var") :
				# 每個指定變數
				var var_list : Array = def_dict["var"]
				for var_name : StringName in var_list :
					# 若目標沒有該變數
					if not var_name in target_obj :
						# 設置 錯誤與原因
						err_to_reason[var_name] = Reason.VAR_NOT_EXIST
						# 設為 不相符
						is_match = false
						if is_skip_if_not_match : break
			# 若 不相符 且 在不相符時跳過 則 直接返回
			if not is_match and is_skip_if_not_match : return report
			
			# 方法
			if def_dict.has("func") :
				# 每個指定的方法
				var func_list : Array = def_dict["func"]
				for each in func_list :
					# 依照指定的方法
					match typeof(each) :
						# 字串
						TYPE_STRING, TYPE_STRING_NAME :
							var func_name : StringName = each
							# 若 目標沒有 該方法
							if not target_obj.has_method(func_name) :
								# 設置 缺少的方法與原因
								err_to_reason[func_name] = Reason.FUNC_NOT_EXIST
								# 設為 不相符
								is_match = false
								if is_skip_if_not_match : break
							
						TYPE_ARRAY :
							# 預設原因為 不存在
							var reason := Reason.FUNC_NOT_EXIST
							
							# 若 方法存在
							var func_name : StringName = each[0]
							if target_obj.has_method(func_name) :
								# 預設原因為 參數數量不符
								reason = Reason.FUNC_ARG_COUNT_ERR
								# 若參數數量相符
								if target.get_method_argument_count(func_name) == each[1] :
									# 忽略此檢查
									continue
							
							# 設置 缺少的方法與原因
							err_to_reason[func_name] = reason
							# 設為 不相符
							is_match = false
							if is_skip_if_not_match : break
						
			# 若 不相符 且 在不相符時跳過 則 直接返回
			if not is_match and is_skip_if_not_match : return report
			
	# 設置 是否相符
	report["is_match"] = is_match
	
	return report

# Private ====================
