extends Node

# Variable ===================

## 偵錯文字
@export 
var debug_label : TextEdit

var is_test_simple_created := false
var is_test_simple_running := false

# GDScript ===================

func _ready () :
	
	G.on_print(func(msg) : 
		self.debug_label.text += msg+"\n"
	, "test_flow")
	
	var Uzil = UREQ.acc("Uzil", "Uzil")
	var Flow = UREQ.acc("Uzil", "Flow")
	
	# 匯入 自訂事件腳本
	Flow.import_event_script("test_event", Uzil.load_script(Flow.PATH.path_join("/_test/test_flow_event.gd")))
	

func _exit_tree () :
	G.off_print("test_flow")

# Extends ====================

# Public =====================

func test_normal () :
	
	var flow_mgr = UREQ.acc("Uzil", "flow_mgr")
	
	# 取得 實例
	var flow = flow_mgr.inst()
	
	# 若 尚未建立 則
	if not self.is_test_simple_created :
		
		# 建立 事件 b
		var b_event = flow.new_event({
			"script":"test_event",
		})
		
		# 建立 節點 b
		var b_chain = flow.new_chain({
			# "script":"base" # 若為 base 可忽略script不填
			"id" : "b_chain",
			"events":[
				b_event.id()
			]
		})
		
		# 建立 事件 a (偵錯print)
		var a_event = flow.new_event({
			"script":"print",
			"msg_enter":"enter A",
			"msg_exit":"exit A, go B",
		})
		
		# 建立 條件 a (計時time)
		var a_gate = flow.new_gate({
			"id":"a_gate",
			"script":"time",
			"time":1000
		})
		
		# 建立 節點 a
		var a_chain = flow.new_chain({
			"id":"a_chain",
			"script":"base",
			"gates":[
				a_gate.id()
			],
			"events":[
				a_event.id()
			],
			# 下一節點 為 b節點
			"next_chains":[
				b_chain.id()
			]
		})
		
		# 連接 b節點 下一節點 為 a節點
		b_chain.add_next(a_chain.id())
		
		self.is_test_simple_created = true
		self.is_test_simple_running = true
		
		# 進入 a節點
		flow.get_chain("a_chain").enter()
		
	else :
	
		if not self.is_test_simple_running :
			flow.get_chain("a_chain").strat().resume()
			flow.get_chain("b_chain").strat().resume()
		else :
			flow.get_chain("a_chain").strat().pause()
			flow.get_chain("b_chain").strat().pause()
		
		self.is_test_simple_running = not self.is_test_simple_running

