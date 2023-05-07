extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	
	G.v.Uzil.audio.key_to_path["test_key"] = G.v.Uzil.Advance.Audio.PATH.path_join("_test/test.ogg")
	
	var layer_test1 = G.v.Uzil.audio.add_layer("layer1").set_volume(1).set_priority(5)
	var _layer_test2 = G.v.Uzil.audio.add_layer("layer2").set_volume(0).set_priority(1)
	
	
	
	var audio_test1 = G.v.Uzil.audio.request("obj1", "test_key", {"bus":"BGM"})
	audio_test1.add_layers(["layer1", "layer2"])
	audio_test1.is_loop = true
	audio_test1.play()
	
#	G.v.Uzil.audio.set_bus_volume("Test", 0)
	
	audio_test1.on_loop.on(func(_ctrlr):
		print("loop")
	)
	
	G.v.Uzil.invoker.inst().once(func () :
		layer_test1.set_priority(-1)
		G.v.Uzil.invoker.inst().once(func () :
			audio_test1.stop()
			print(G.v.Uzil.audio.emit("test_key")._id)
		, 5000)	
	, 5000)

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

