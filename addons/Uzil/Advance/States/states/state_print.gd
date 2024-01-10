
# Variable ===================

var state = null
var user = null

var msg_enter := ""
var msg_process := ""
var msg_exit := ""

# GDScript ===================

# Extends ====================

# Interface ==================

## 設置 狀態
func set_state (_state) :
	self.state = _state

## 設置 使用主體
func set_user (_user) :
	self.user = _user

## 設置 資料
func set_data (data) :
	if data.has("msg") :
		self.msg_enter = data["msg"]
	if data.has("msg_enter") :
		self.msg_enter = data["msg_enter"]
	if data.has("msg_process") :
		self.msg_process = data["msg_process"]
	if data.has("msg_exit") :
		self.msg_exit = data["msg_exit"]

## 初始化
func init (_user) :
	pass

## 推進
func process (_dt) :
	if self.msg_process.is_empty() : return
	G.print(self.msg_process)

## 當 狀態 進入
func on_enter () :
	if self.msg_enter.is_empty() : return
	G.print(self.msg_enter)

## 當 狀態 離開
func on_exit () :
	if self.msg_exit.is_empty() : return
	G.print(self.msg_exit)

# Public =====================

# Private ====================

