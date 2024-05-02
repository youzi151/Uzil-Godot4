
## Evt.CallCtrlr 事件呼叫控制
## 
## 事件呼叫的過程中, 用來控制是否停止.
## 特定/忽略標籤 會用在 與 listener.tags 來 決定該listener應不應該被處理.
## 

# Variable ===================

signal on_done

## 事件
var _evt = null

## 當前偵聽者
var _current_listener = null

## 是否已停止呼叫
var _is_call_stop := false

## 是否等候中
var _is_wait := false

## 特定標籤
var _attend_tags := []

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


## 暫停
func wait () :
	self._is_wait = true

## 等候至完成
func until_done () :
	if self._is_wait : await self.on_done

## 完成
func done () :
	self._is_wait = false
	self.on_done.emit()
	

## 指定
func attend (tag : String) :
	if not self._attend_tags.has(tag) :
		self._attend_tags.push_back(tag)

## 指定
func attends (tags : Array) :
	for each in tags :
		self.attend(each)

## 忽略
func ignore (tag : String) :
	if not self._ignore_tags.has(tag) :
		self._ignore_tags.push_back(tag)

## 忽略
func ignores (tags : Array) :
	for each in tags :
		self.ignore(each)

## 是否應該被處理
func should_handle (tags : Array) -> bool :
	for each in tags :
		if self._ignore_tags.has(each) : return false
	
	if self._attend_tags.size() > 0 :
		for each in self._attend_tags :
			if not tags.has(each) :
				return false
			
		
	return true
