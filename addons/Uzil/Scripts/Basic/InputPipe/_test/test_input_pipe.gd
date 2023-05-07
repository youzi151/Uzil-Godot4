extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	var input_layer1 = G.v.Uzil.input_pipe.get_layer("L1")
	var input_layer2 = G.v.Uzil.input_pipe.get_layer("L2")
	
	var handler = G.v.Uzil.Basic.InputPipe.new_handler("test", "keyconvert", {
		"src" : [G.v.Uzil.Util.input.keycode.name_to_keycode("key.a")],
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
	
#	G.v.Uzil.invoker.inst().once(func():
#		input_layer1.aaaaa(false)
#	, 2000)

func test_process(_delta):
	pass

# Public =====================

