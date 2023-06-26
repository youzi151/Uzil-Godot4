extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	
	var Audio = UREQ.acc("Uzil", "Audio")
	var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
	audio_mgr.key_to_path["test_key"] = Audio.PATH.path_join("_test/test.ogg")
	
	var layer_test1 = audio_mgr.add_layer("layer1").set_volume(1).set_priority(5)
	var _layer_test2 = audio_mgr.add_layer("layer2").set_volume(0).set_priority(1)
	
	
	
	var audio_test1 = audio_mgr.request("obj1", "test_key", {"bus":"BGM"})
	audio_test1.add_layers(["layer1", "layer2"])
	audio_test1.is_loop = true
	audio_test1.play()
	
#	audio_mgr.set_bus_volume("Test", 0)
	
	audio_test1.on_loop.on(func(_ctrlr):
		print("loop")
	)
	
	var invoker = invoker_mgr.inst()
	invoker.once(func () :
		layer_test1.set_priority(-1)
		invoker.once(func () :
			audio_test1.stop()
			print(audio_mgr.emit("test_key")._id)
		, 5000)	
	, 5000)

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

