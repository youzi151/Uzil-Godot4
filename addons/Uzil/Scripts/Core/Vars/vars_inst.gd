
## Vars 變數庫
##
## 提供 具有明確介面 的 區域變數存取
##

# Variable ===================

## 鍵:資料 表
var _key_to_data := {}

## 當 數值 改變
var _on_var_changed = null

# GDScript ===================

func _init () :
	var Evt = UREQ.acc("Uzil", "Core.Evt")
	self._on_var_changed = Evt.Inst.new()

# Public =====================

## 是否有
func has_key (key : String) :
	return self._key_to_data.has(key)

## 取得 變數
func get_var (key : String) :
	if self._key_to_data.has(key) :
		return self._key_to_data[key]
	else :
		return null

## 取得 變數
func set_var (key : String, val) :
	var exist = null
	if self._key_to_data.has(key)  :
		exist = self._key_to_data[key]
	
	if val != null :	
		self._key_to_data[key] = val
	else :
		self._key_to_data.erase(key)
	
	var data = {
		"key":key,
		"val":val,
	}
	if exist != null :
		data["last"] = exist
		
	self._on_var_changed.emit(data)

## 註冊 當 變數 改變
func on_var_changed (listener_or_fn) :
	return self._on_var_changed.on(listener_or_fn)

## 註銷 當 變數 改變
func off_var_changed (listener_or_tag) :
	self._on_var_changed.off(listener_or_tag)
