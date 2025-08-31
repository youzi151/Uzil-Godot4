
## Vars 變數庫
##
## 提供 具有明確介面 的 區域變數存取.
##

# Variable ===================

## 鍵:資料 表
var _key_to_val := {}

## 當 數值 改變
var _on_vars_changed = null

## 變數 請求器
var req_vars_fn : Callable

# GDScript ===================

func _init () :
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	self._on_vars_changed = Evt.Inst.new()

# Public =====================

## 是否有
func has_var (key: String) :
	return self._key_to_val.has(key)

## 取得 變數表
func get_vars () :
	return self._key_to_val

## 取得 變數
func get_var (key: String, _default_val = null) :
	if self._key_to_val.has(key) :
		return self._key_to_val[key]
	else :
		return _default_val

## 設置 變數表
func set_vars (key_to_val: Dictionary) :
	var key_to_change_info := {}
	for key in key_to_val :
		key_to_change_info[key] = self.set_var(key, key_to_val[key], false)
	self._on_vars_changed.emit(key_to_change_info)

## 設置 變數
func set_var (key: String, val, is_trigger_evt := true) :
	var exist = null
	if self._key_to_val.has(key)  :
		exist = self._key_to_val[key]
	
	if val != null :
		self._key_to_val[key] = val
	else :
		self._key_to_val.erase(key)
	
	# 變更資訊
	var change_info := {
		"val": val,
		"last": exist,
		"is_del": false,
	}
	
	# 若 要觸發事件
	if is_trigger_evt :
		# 呼叫事件 {變數key:變更資訊}
		self._on_vars_changed.emit({
			key: change_info
		})
	
	return change_info

## 移除 變數表
func del_vars (keys = null) :
	if keys == null : keys = self._key_to_val.keys()
	
	var key_to_change_info := {}
	for key in keys :
		key_to_change_info[key] = self.del_var(key, false)
	
	self._on_vars_changed.emit(key_to_change_info)

## 移除 變數
func del_var (key: String, is_trigger_evt := true) :
	if not self._key_to_val.has(key) : return
	
	var exist = self._key_to_val[key]
	self._key_to_val.erase(key)
	
	# 變更資訊
	var change_info := {
		"val":null,
		"last": exist,
		"is_del": true,
	}
	
	# 若 要觸發事件
	if is_trigger_evt :
		# 呼叫事件 {變數key:變更資訊}
		self._on_vars_changed.emit({
			key: change_info
		})
	
	return change_info

## 請求 變數
func req_var (key: String, _default_val = null) :
	var vars : Dictionary = self.req_vars([key])
	if not vars.has(key) : return _default_val
	return vars[key]

## 請求 變數表
func req_vars (_keys := []) :
	
	# 請求函式 是否存在
	var is_req_vars_fn_exist : bool = not self.req_vars_fn.is_null()
	
	# 結果 若請求函式存在 則 建立副本 否則 使用空字典
	var result : Dictionary = self._key_to_val.duplicate() if is_req_vars_fn_exist else {}
	
	# 若請求函式存在
	if is_req_vars_fn_exist : 
		# 呼叫請求函式
		var args : Array = [result, _keys]
		args.resize(self.req_vars_fn.get_argument_count())
		var new_one = self.req_vars_fn.callv(args)
		# 若 回傳 存在 則 以此為新結果
		if new_one != null :
			result = new_one
	else :
		# 若 有指定key
		if _keys.size() > 0 :
			# 逐個複製
			for key in _keys :
				if not self._key_to_val.has(key) : continue
				result[key] = self._key_to_val[key]
		# 否則 複製全部
		else :
			result = self._key_to_val.duplicate()
	return result

## 註冊 當 變數 改變
func on_vars_changed (listener_or_fn) :
	return self._on_vars_changed.on(listener_or_fn)

## 註銷 當 變數 改變
func off_vars_changed (listener_or_tag) :
	self._on_vars_changed.off(listener_or_tag)
