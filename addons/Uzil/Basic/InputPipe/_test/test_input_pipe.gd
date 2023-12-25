extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	var InputPipe = UREQ.acc("Uzil", "InputPipe")
	var input_pipe = UREQ.acc("Uzil", "input_pipe")
	var Util = UREQ.acc("Uzil", "Util")
	
	var input_layer1 = input_pipe.get_layer("L1").sort(1)
	var input_layer2 = input_pipe.get_layer("L2").sort(2)
	var input_layer3 = input_pipe.get_layer("L3").sort(3)
	var input_layer4 = input_pipe.get_layer("L4").sort(4)
	
	# 輸入處理器 a -> 123
	var handler1 = InputPipe.new_handler("test1", "keyconvert", {
		"src" : [Util.input.keycode.name_to_keycode("key.a")],
		"dst" : 123
	})
	# 輸入處理器 s -> 321
	var handler2 = InputPipe.new_handler("test2", "keyconvert", {
		"src" : [Util.input.keycode.name_to_keycode("key.s")],
		"dst" : 321
	})
	
	# Handler 1
	input_layer1.add_handler(handler1)
	input_layer2.add_handler(handler1)
	input_layer3.add_handler(handler1)
	input_layer4.add_handler(handler1)
	
	# Handler 2
	input_layer2.add_handler(handler2)
	
	# Layer 1
	
	# Listener 1
	input_layer1.on_input(123, func(ctrlr):
		
		self.test_print_clear()
		
		var input_msg = ctrlr.data
		self.test_print("Layer1 1 key[123] val:%s" % input_msg.val)
		
		if input_msg.val == 1 :
			ctrlr.ignore("to_ignore_listener_aaa")
			input_msg.ignore("to_ignore_listener_aaa")
	)
	# Listener 2
	input_layer1.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer1 2 key[123] val:%s" % input_msg.val)
	).tag("to_ignore_listener_aaa")
	# Listener 3
	input_layer1.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer1 3 key[123] val:%s" % input_msg.val)
		if input_msg.val == 1 :
			ctrlr.stop()
#			input_msg.stop()
	)
	# Listener 4
	input_layer1.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer1 4 key[123] val:%s" % input_msg.val)
	)
	
	# Layer 2
	
	# Listener (321)
#	input_layer2.on_input(321, func(ctrlr):
#		var input_msg = ctrlr.data
#		self.test_print("Layer2 key[321] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
#	)
	# Listener 1
	input_layer2.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer2 key[123] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
	).tag("to_ignore_listener_aaa")
	
	# Layer 3
	
	# Listener 1
	input_layer3.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer3 key[123] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
		if input_msg.val == 1 :
			input_msg.stop()
	)
	
	# Layer 4
	
	# Listener 1
	input_layer4.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		self.test_print("Layer4 key[123] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
	)
	
#	UREQ.acc("Uzil", "invoker").inst().once(func():
#		input_layer1.aaaaa(false)
#	, 2000)

func test_process(_delta):
	pass

# Public =====================

