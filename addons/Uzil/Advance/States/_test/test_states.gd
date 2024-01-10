extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 實例
var states_inst = null

## 是否測試log中
var is_testing_log := false

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_states")
	

func _process (_dt) :
	if self.states_inst != null :
		self.states_inst.process(_dt)

func _exit_tree () :
	G.off_print("test_states")

# Extends ====================

func test_log () :
	
	var states_mgr = UREQ.acc("Uzil", "states_mgr")
	var invoker = UREQ.acc("Uzil", "invoker")
	
	# 取得 實例
	var inst = states_mgr.inst("test")
	self.states_inst = inst
	
	# 若 測試中 則
	if self.is_testing_log :
		self.is_testing_log = false
		
		# 前往 空 狀態
		inst.go_state(null, true)
		# 取消 相關呼叫
		invoker.cancel_tag("test_ui_states_log")
		
		# 跳出
		return
	
	
	# 設為 測試中
	self.is_testing_log = true
	
	# 建立狀態
	inst.del_state("a")
	inst.del_state("b")
	var state_a = inst.new_state("a", "print", {"msg":"enter State A"})
	var state_b = inst.new_state("b", "print", {"msg":"enter State B"})
	
	# 開始 與 初始化
	inst.unlock()
	inst.start()
	
	# 前往 狀態A
	inst.go_state("a")
	
	# 鎖住狀態
	G.print("lock")
	inst.lock()
	
	# 計時 數秒後
	invoker.once(func():
		# 前往 狀態B
		inst.go_state("b")
		
		# 嘗試前往狀態B 但應被鎖住
		G.print("goto b state")
		
		# 計時 數秒後
		invoker.once(func():
			
			# 解鎖
			G.print("unlock")
			inst.unlock()
			
		, 2000).tag("test_ui_states_log")
		
	, 1000).tag("test_ui_states_log")
	


# Public =====================

