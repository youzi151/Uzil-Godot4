
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

## 初始化設置
func setup (runtime, state) :
	var data : Dictionary = state.data
	var vars = runtime.vars(state)
	
	if data.has("msg_enter") :
		vars.set_var("msg_enter", data["msg_enter"])
	elif data.has("msg") :
		vars.set_var("msg_enter", data["msg"])
	
	if data.has("msg_process") :
		vars.set_var("msg_process", data["msg_process"])
	
	if data.has("msg_exit") :
		vars.set_var("msg_exit", data["msg_exit"])

## 推進
func process (runtime, state, _dt) :
	var msg : String = runtime.vars(state).get_var("msg_process", "")
	if msg.is_empty() : return
	G.print(msg)

## 當 狀態 進入
func on_enter (runtime, state) :
	var msg : String = runtime.vars(state).get_var("msg_enter", "")
	if msg.is_empty() : return
	G.print(msg)

## 當 狀態 離開
func on_exit (runtime, state) :
	var msg : String = runtime.vars(state).get_var("msg_exit", "")
	if msg.is_empty() : return
	G.print(msg)

# Public =====================

# Private ====================
