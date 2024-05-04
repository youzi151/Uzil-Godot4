
## Evt.Listener 偵聽者
## 
## 提供 事件 識別 與 呼叫 執行內容
## 

# Variable ===================

## 標籤
var tags : Array[String] = []

## 執行內容
var fnc : Callable

## 排序
var sort : int = 0

## 呼叫次數 (預設 無限)
var call_times : int = -1

# GDScript ===================

# Public =====================

## 呼叫事件
func emit (ctrlr) :
	
	var is_ctrlr_exist := ctrlr != null
	
	if is_ctrlr_exist :
		ctrlr.set_current_listener(self)
	
	# 雖有 Callable.get_argument_count() 可用.
	# 但應用在有capture區域變數的lambda時, 會因為capture的變數也會被包含其數量中, 導致非預期的結果.
	# 故固定傳入單一變數ctrlr較佳.
	await self.fnc.call(ctrlr)
	
	if is_ctrlr_exist :
		await ctrlr.until_done()
	
	if is_ctrlr_exist : 
		ctrlr.set_current_listener(null)

## 設置 執行內容
func fn (_fn: Callable) :
	self.fnc = _fn
	return self

## 設置 呼叫次數
func times (times: int) :
	self.call_times = times
	return self

## 設置 單次呼叫
func once () :
	self.call_times = 1
	return self

## 設置 排序
func srt (_srt: int) :
	self.sort = _srt
	return self

## 設置 標籤
func tag (_tag: String) :
	if not self.tags.has(_tag) :
		self.tags.push_back(_tag)
	return self

## 是否有該標籤
func is_tag (_tag) :
	return self.tags.has(_tag)
