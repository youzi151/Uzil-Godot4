
## Flow.Gate_Time 流程控制 條件 時間倒數
##
## 依照指定的時間實進行倒數計時, 倒數完畢後 即 完成條件
##

var times_mgr

# Variable ===================

## 殼
var _shell = null

## 呼叫器/多重時間 鍵值
var _inst_key := ""

## 時間
var _time_msec := 0

## 剩餘時間
var _left_time := 0

# GDScript ===================

func _init () :
	self.times_mgr = UREQ.access_g("Uzil", "times_mgr")

# Interface ====================

## 設置 殼
func _set_shell (shell) :
	self._shell = shell

## 當 初始化 
func _on_init (_init_data) :
	pass

## 讀取 紀錄
func _load_memo (_memo : Dictionary) :
	
	if _memo.has("time_key") :
		self._inst_key = _memo["time_key"]
	
	if _memo.has("time") :
		self._time_msec = _memo["time"]
	if _memo.has("time_msec") :
		self._time_msec = _memo["time_msec"]
	if _memo.has("time_sec") :
		self._time_msec = _memo["time_sec"] * 1000
	
	if _memo.has("left_time") :
		self._left_time = _memo["left_time"]
		
## 匯出 紀錄
func _to_memo (_memo, _args) :
	
	_memo["time_key"] = self._inst_key
	_memo["time_msec"] = self._time_msec
	_memo["left_time"] = self._left_time

	return _memo
	
## 當 進入
func _on_enter () :
	self._shell.reset()

## 當 每幀更新
func _on_process (_dt) :
	if self._shell.is_complete() : return
	
	self._left_time -= self.times_mgr.inst(self._inst_key).dt()
	
	if self._left_time <= 0 :
		self._shell.complete()

## 當 暫停
func _on_pause () :
	pass

## 當 恢復
func _on_resume () :
	pass

## 當 離開
func _on_exit () :
	pass

## 當 重設
func _on_reset () :
	self._left_time = self._time_msec

# Public =====================

# Private ====================
