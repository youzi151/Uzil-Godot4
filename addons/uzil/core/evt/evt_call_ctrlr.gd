
## Evt.CallCtrlr 事件呼叫控制
## 
## 事件呼叫的過程中, 用來控制是否停止.
## tags 會用在 與 listener的require/only/ignore 來 決定該listener應不應該處理.
## 

# Variable ===================

signal on_resume

## 事件
var _evt = null

## 當前偵聽者
var _current_listener = null

## 是否已停止呼叫
var _is_call_stop := false

## 是否暫停中
var _is_pause := false

## 標籤
var tags := []

## 資料
var data = null


# GDScript ===================

func _init (__evt) :
	self._evt = __evt

# Public =====================

## 設置標籤
func tag (_tag: String) :
	if not self.tags.has(_tag) :
		self.tags.push_back(_tag)
	return self

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
func pause () :
	self._is_pause = true

## 暫停至恢復
func until_resume () :
	if self._is_pause : await self.on_resume

## 恢復
func resume () :
	self._is_pause = false
	self.on_resume.emit()
