extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	var InputPipe = UREQ.access_g("Uzil", "InputPipe")
	var input_pipe = UREQ.access_g("Uzil", "input_pipe")
	var Util = UREQ.access_g("Uzil", "Util")
	
	var input_layer1 = input_pipe.get_layer("L1")
	var input_layer2 = input_pipe.get_layer("L2")
	
	var handler = InputPipe.new_handler("test", "keyconvert", {
		"src" : [Util.input.keycode.name_to_keycode("key.a")],
		"dst" : 123
	})
	
	print(handler.src_keys)
	
	input_layer1.add_handler(handler)
	input_layer2.add_handler(handler)
	
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
	
#	UREQ.access_g("Uzil", "invoker").inst().once(func():
#		input_layer1.aaaaa(false)
#	, 2000)

func test_process(_delta):
	pass

# Public =====================

