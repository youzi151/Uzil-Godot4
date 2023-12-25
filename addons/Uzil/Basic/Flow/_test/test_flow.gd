extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	
	var Uzil = UREQ.acc("Uzil", "Uzil")
	var Flow = UREQ.acc("Uzil", "Flow")
	var flow_mgr = UREQ.acc("Uzil", "flow_mgr")
	
	Flow.import_event_script("test_event", Uzil.load_script(Flow.PATH.path_join("/_test/test_flow_event.gd")))
	
	var flow = flow_mgr.inst()
	
	var b_event = flow.new_event({
		"script":"test_event",
	})
	
	var b_chain = flow.new_chain({
#		"script":"base"
		"id" : "b_chain",
		"events":[
			b_event.id()
		]
	})
	
	var a_event = flow.new_event({
		"script":"print",
		"msg_enter":"hello",
		"msg_exit":"world",
	})
	
	var a_gate = flow.new_gate({
		"id":"a_gate",
		"script":"time",
		"time":1000
	})
	
	var a_chain = flow.new_chain({
		"id":"a_chain",
		"script":"base",
		"gates":[
			a_gate.id()
		],
		"events":[
			a_event.id()
		],
		"next_chains":[
			b_chain.id()
		]
	})
	
	b_chain.add_next(a_chain.id())
	
	a_chain.enter()
	

func test_process(_delta):
	pass

# Public =====================

