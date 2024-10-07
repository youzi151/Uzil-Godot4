

## Invoker.Task 呼叫器 任務
## 
## 紀錄 呼叫器 使用所需的 資料 與 執行內容
##

# Variable ===================

## 信號
signal on_done

## 行為
var fn : Callable

## 時間
var calltime_ms : int = 0

## 間隔
var interval_ms : int = 0

## 呼叫類型
var call_type : int = 0

## 標籤
var tags : Array[String] = []

## 排序
var sort : int = 0

## 重要性 (非排序依據, 而是作為是否取代的依據)
var priority : int = 0

## 自動排序
var auto_sort : int = 0

# GDScript ===================

func _init () :
	var Invoker = UREQ.acc(&"Uzil:Core.Invoker")
	self.call_type = Invoker.CallType.ONCE

# Public =====================

## 呼叫
func run () :
	self.fn.call()

## 呼叫 (帶單個參數)
func run_arg (arg) :
	self.fn.call(arg)

## 完成
func done () :
	self.on_done.emit()

## 標籤
func tag (tag_str: String) :
	if not self.tags.has(tag_str):
		self.tags.push_back(tag_str)
	return self
