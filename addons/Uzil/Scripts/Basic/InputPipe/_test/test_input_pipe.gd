extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	var InputPipe = UREQ.acc("Uzil", "InputPipe")
	var input_pipe = UREQ.acc("Uzil", "input_pipe")
	var Util = UREQ.acc("Uzil", "Util")
	
	var input_layer1 = input_pipe.get_layer("L1")
	var input_layer2 = input_pipe.get_layer("L2")
	
	var handler1 = InputPipe.new_handler("test1", "keyconvert", {
		"src" : [Util.input.keycode.name_to_keycode("key.a")],
		"dst" : 123
	})
	
	var handler2 = InputPipe.new_handler("test2", "keyconvert", {
		"src" : [Util.input.keycode.name_to_keycode("key.s")],
		"dst" : 321
	})
	
	print(handler1.src_keys)
	
	input_layer1.add_handler(handler1)
	input_layer2.add_handler(handler1)
	
	input_layer2.add_handler(handler2)
	
	input_layer1.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		print("Layer1 1 key[123] val:%s" % input_msg.val)
		if input_msg.val == 1 :
			ctrlr.stop()
			input_msg.stop()
	)
	input_layer1.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		print("Layer1 2 key[123] val:%s" % input_msg.val)
	)
	
	input_layer2.on_input(123, func(ctrlr):
		var input_msg = ctrlr.data
		print("Layer2 key[123] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
	)
	
	input_layer2.on_input(321, func(ctrlr):
		var input_msg = ctrlr.data
		print("Layer2 key[321] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
	)
	
#	UREQ.acc("Uzil", "invoker").inst().once(func():
#		input_layer1.aaaaa(false)
#	, 2000)

func test_process(_delta):
	pass

# Public =====================

