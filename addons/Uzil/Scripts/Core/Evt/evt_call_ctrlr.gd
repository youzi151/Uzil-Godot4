
## Evt.CallCtrlr 事件呼叫控制
## 
## 事件呼叫的過程中, 用來控制是否停止
## 

# Variable ===================

## 是否已停止呼叫
var _is_call_stop := false

## 事件
var _evt = null

## 資料
var data = null

# GDScript ===================

func _init (__evt) :
	self._evt = __evt

# Public =====================

## 停止呼叫
func stop () :
	self._is_call_stop = true

## 取得事件
func evt () :
	return self._evt

## 是否已經停止呼叫
func is_call_stop () :
	return self._is_call_stop
