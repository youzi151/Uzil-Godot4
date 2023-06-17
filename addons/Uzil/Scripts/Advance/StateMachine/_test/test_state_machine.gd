extends Uzil_Test_Base

# Variable ===================

var state_machine_inst = null

# Extends ====================

func test_ready():
	var states_mgr = UREQ.access_g("Uzil", "states_mgr")
	var invoker_mgr = UREQ.access_g("Uzil", "invoker_mgr")
	
	var inst = states_mgr.inst("test")
	
	var state_a = inst.new_state("print", "a", {"msg":"i'm a"})
	var state_b = inst.new_state("print", "b", {"msg":"i'm b"})
	
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
	
	self.state_machine_inst = inst

func test_process(_delta):
	self.state_machine_inst.process(_delta)

# Public =====================

