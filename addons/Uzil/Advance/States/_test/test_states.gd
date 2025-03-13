extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export
var states_inst_node : Node = null

## 執行個體
var runtime = null

## 節點上的實例
var node_inst = null

## 是否測試log中
var is_testing_log := false

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_states")
	

func _process (_dt) :
	if self.node_inst != null :
		self.node_inst.process(_dt)

func _exit_tree () :
	G.off_print("test_states")

# Extends ====================

func test_log () :
	
	var invoker = UREQ.acc(&"Uzil:invoker")
	
	if self.runtime == null :
		
		# 取得 實例
		var states_mgr = UREQ.acc(&"Uzil:states_mgr")
		var inst = states_mgr.inst("test")
		
		# 建立狀態
		var state_a = inst.new_state("a", {
			"handlers": ["print"],
			"transitions": ["trans_a_b"],
			"data": {
				"msg_enter":"enter State A",
				#"msg_process":"process State A",
				"msg_exit":"exit State A",
			}
		})
		
		var trans_a_b = inst.new_transition("trans_a_b", {
			"to_state": "b",
			"handlers": ["wait_sec"],
			"conditions": ["toggle_on"],
			"data": {
				"wait_sec": 1
			}
		})
		var cond_toggle_on = inst.new_condition("toggle_on", {
			"handlers": ["vars_equals"],
			"data": {
				"vars_equals": {
					"toggle_test": true
				}
			}
		})
		
		var state_b = inst.new_state("b", {
			"handlers": ["print"],
			"transitions": ["trans_b_c"],
			"data": {
				"msg_enter":"enter State B",
				#"msg_process":"process State B",
				"msg_exit":"exit State B",
			}
		})
		
		var trans_b_c = inst.new_transition("trans_b_c", {
			"to_state": "c",
			"handlers": ["wait_sec"],
			"conditions": [],
			"condition_exp": "vars.get_var(\"toggle_expression\", false)",
			"data": {
				"wait_sec": 1
			}
		})
		
		var state_c = inst.new_state("c", {
			"handlers": ["print"],
			"transitions": ["trans_c_null"],
			"data": {
				"msg_enter":"enter State C",
				#"msg_process":"process State C",
				"msg_exit":"exit State C",
			}
		})
		
		var trans_c_null = inst.new_transition("trans_c_null", {
			"to_state": "",
		})
		
		self.runtime = inst.new_runtime()
		UREQ.acc(&"Uzil:invoker").update(func(dt):
			self.runtime.process(dt)
		)
		await self.runtime.setup()
		
	
	# 若 測試中 則
	if self.is_testing_log :
		self.is_testing_log = false
		
		# 前往 空 狀態
		self.runtime.go_state(null, true)
		# 取消 相關呼叫
		invoker.cancel_tag("test_ui_states_log")
		G.print("test done")
		
		# 跳出
		return
	
	
	# 設為 測試中
	self.is_testing_log = true
	
	
	# 開始 與 初始化
	self.runtime.unlock()
	
	# 前往 狀態A
	self.runtime.go_state("a")
	
	# 鎖住狀態
	G.print("lock")
	self.runtime.lock()
	
	# 計時 數秒後
	invoker.once(func():
		# 前往 狀態B
		#self.runtime.go_state("b")
		self.runtime.vars().set_var("toggle_test", true)
		
		# 嘗試前往狀態B 但應被鎖住
		G.print("toggle_test = true")
		
	, 1000).tag("test_ui_states_log")
	
	# 計時 數秒後
	invoker.once(func():
		
		# 解鎖
		G.print("unlock")
		self.runtime.unlock()
		
		self.is_testing_log = false
		
	, 2000).tag("test_ui_states_log")
	
	# 計時 數秒後
	invoker.once(func():
		
		self.runtime.vars().set_var("toggle_expression", true)
		
		G.print("toggle_expression = true")
		
	, 5000).tag("test_ui_states_log")
	


func test_node () :
	self.node_inst = self.states_inst_node.request_inst()
	var node_runtime = self.node_inst.new_runtime()
	node_runtime.start()
	
	var invoker = UREQ.acc(&"Uzil:invoker")
	invoker.once(func():
		node_runtime.vars().set_var("toggle_expression", true)
		G.print("toggle_expression = true")
	, 3000)
	
	invoker.once(func():
		node_runtime.vars().set_var("toggle_var", true)
		G.print("toggle_var = true")
	, 6000)

# Public =====================
