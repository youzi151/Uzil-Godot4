
## Invoker.Task 呼叫器 任務
## 
## 紀錄 呼叫器 使用所需的 資料 與 執行內容
##

# Variable ===================

## 行為
var fn : Callable

## 時間
var calltime_ms := 0

## 間隔
var interval_ms := 0

## 呼叫類型
var call_type : int = 0

## 標籤
var tags : Array[String] = []

## 排序
var sort := 0

## 重要性
var priority := 0

## 自動排序
var auto_sort := 0

# GDScript ===================

func _init () :
	var Invoker = UREQ.acc("Uzil", "Invoker")
	self.call_type = Invoker.CallType.ONCE

# Public =====================

## 呼叫
func run () :
	self.fn.call()

## 呼叫 (帶參數)	
func runArg (args) :
	self.fn.call(args)

## 標籤
func tag (tag_str : String) :
	if self.tags.has(tag_str):
		return
	else:
		self.tags.push_back(tag_str)
