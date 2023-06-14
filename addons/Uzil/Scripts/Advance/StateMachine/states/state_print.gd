
# Variable ===================

var state = null
var user = null

var msg := ""

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
	self.msg = data.msg

## 初始化
func init (_user) :
	pass

## 推進
func process (_dt) :
	print("[test state_print] state[%s] dt[%s]" % [self.state.id, _dt])

## 當 狀態 進入
func on_enter () :
	print_debug("[test state_print] on_enter user = %s, msg = %s" % [self.user, self.msg])

## 當 狀態 離開
func on_exit () :
	print_debug("[test state_print] on_exit user = %s, msg = %s" % [self.user, self.msg])

# Public =====================

# Private ====================

