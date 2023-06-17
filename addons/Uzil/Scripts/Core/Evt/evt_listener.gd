
## Evt.Listener 偵聽者
## 
## 提供 事件 識別 與 呼叫 執行內容
## 

# Variable ===================

## 標籤
var tags : Array[String] = []

## 執行內容
var fnc = null

## 排序
var sort := 0

# GDScript ===================

# Public =====================

## 呼叫事件
func emit (ctrlr) :
	self.fnc.call(ctrlr)

## 設置 執行內容
func fn (_fn: Callable) :
	self.fnc = _fn
	return self

## 設置 排序
func srt (_srt : int) :
	self.sort = _srt
	return self

## 設置 標籤
func tag (_tag : String) :
	if not self.tags.has(_tag) :
		self.tags.push_back(_tag)
	return self

## 是否有該標籤
func is_tag (_tag) :
	return self.tags.has(_tag)
