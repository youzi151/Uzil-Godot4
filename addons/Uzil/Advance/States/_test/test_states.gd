extends Uzil_Test_Base

# Variable ===================

var states_inst = null

# Extends ====================

func test_ready():
	var states_mgr = UREQ.acc("Uzil", "states_mgr")
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
	var inst = states_mgr.inst("test")
	
	var state_a = inst.new_state("a", "print", {"msg":"i'm a"})
	var state_b = inst.new_state("b", "print", {"msg":"i'm b"})
	
	inst.start()
	inst.go_state("a")
	
	print("lock")
	inst.lock()
	
	invoker_mgr.inst().once(func():
		inst.go_state("b")
		print("goto b state")
		invoker_mgr.inst().once(func():
			print("unlock")
			inst.unlock()
		, 2000)
	, 2000)
	
	self.states_inst = inst

func test_process(_delta):
	self.states_inst.process(_delta)

# Public =====================

