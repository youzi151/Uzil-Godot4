
## Vars 變數庫
##
## 提供 具有明確介面 的 區域變數存取.
##

# Variable ===================

## 鍵:資料 表
var _key_to_val := {}

## 當 數值 改變
var _on_var_changed = null

## 變數 請求器
var req_vars_fn : Callable

# GDScript ===================

func _init () :
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	self._on_var_changed = Evt.Inst.new()

# Public =====================

## 是否有
func has_var (key: String) :
	return self._key_to_val.has(key)

## 取得 變數
func get_var (key: String, _default_val = null) :
	if self._key_to_val.has(key) :
		return self._key_to_val[key]
	else :
		return _default_val

## 取得 變數
func set_var (key: String, val) :
	var exist = null
	if self._key_to_val.has(key)  :
		exist = self._key_to_val[key]
	
	if val != null :
		self._key_to_val[key] = val
	else :
		self._key_to_val.erase(key)
	
	var data = {
		"key":key,
		"val":val,
	}
	if exist != null :
		data["last"] = exist
		
	self._on_var_changed.emit(data)

## 移除 變數
func del_var (key: String) :
	self.set_var(key, null)

## 取得 變數表
func get_vars () :
	return self._key_to_val

## 設置 變數表
func set_vars (key_to_val: Dictionary) :
	self._key_to_val.merge(key_to_val, true)

## 清除 變數表
func clear_vars () :
	self._key_to_val.clear()

## 請求 變數表
func req_vars (_keys := []) :
	var result : Dictionary = self._key_to_val.duplicate(true)
	if not self.req_vars_fn.is_null() : 
		var new_one = self.req_vars_fn.call(result, _keys)
		if new_one != null :
			result = new_one
	return result

## 修改 變數表
func mod_vars (fn: Callable) :
	var new_one = fn.call(self._key_to_val)
	if new_one != null and typeof(new_one) == TYPE_DICTIONARY :
		self._key_to_val = new_one

## 註冊 當 變數 改變
func on_var_changed (listener_or_fn) :
	return self._on_var_changed.on(listener_or_fn)

## 註銷 當 變數 改變
func off_var_changed (listener_or_tag) :
	self._on_var_changed.off(listener_or_tag)
