
## Flow.Event_Print 流程控制 事件 印出
##
## 測試, 印出log用
##

# Variable ===================

## 核心
var _core = null

## 當 進入時 訊息
var msg_enter := ""
## 當 離開時 訊息
var msg_exit := ""

# GDScript ===================

# Interface ==================

## 設置 核心
func _set_core (core) :
	self._core = core

## 當 初始化 
func _on_init (_init_data) :
	pass

## 讀取 紀錄
func _load_memo (_memo : Dictionary) :
	
	if _memo.has("msg") :
		self.msg_enter = _memo["msg"]
		
	if _memo.has("msg_enter") :
		self.msg_enter = _memo["msg_enter"]
		
	if _memo.has("msg_exit") :
		self.msg_exit = _memo["msg_exit"]
	
## 匯出 紀錄
func _to_memo (_memo, _args) :
	
	_memo["msg_enter"] = self.msg_enter
	_memo["msg_exit"] = self.msg_exit
	
	return _memo

## 進入
func _on_enter () :
	if self.msg_enter == null : return
	G.print(self.msg_enter)

## 離開
func _on_exit () :
	if self.msg_exit == null : return
	G.print(self.msg_exit)

# Public =====================

# Private ====================
