
## Evt.CallCtrlr 事件呼叫控制
## 
## 事件呼叫的過程中, 用來控制是否停止
## 

# Variable ===================

## 事件
var _evt = null

## 當前偵聽者
var _current_listener = null

## 是否已停止呼叫
var _is_call_stop := false

## 忽略標籤
var _ignore_tags := []

## 資料
var data = null

# GDScript ===================

func _init (__evt) :
	self._evt = __evt

# Public =====================

## 取得事件
func evt () :
	return self._evt

## 設置 當前偵聽者
func set_current_listener (listener) :
	self._current_listener = listener

## 取得 當前偵聽者
func current_listener () :
	return self._current_listener

## 停止呼叫
func stop () :
	self._is_call_stop = true

## 是否已經停止呼叫
func is_call_stop () -> bool :
	return self._is_call_stop

## 忽略
func ignore (tag : String) :
	if not self._ignore_tags.has(tag) :
		self._ignore_tags.push_back(tag)

## 忽略
func ignores (tags : Array[String]) :
	for each in tags :
		self.ignore(each)

## 取得 忽略標籤
func get_ignores () -> Array[String] :
	return self._ignore_tags

## 是否忽略
func is_ignores (tags : Array[String]) -> bool :
	for each in self._ignore_tags :
		if tags.has(each) : return true
	return false
