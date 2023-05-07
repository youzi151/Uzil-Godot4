extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
#	pass
#	print("fullscreen mode : %s" % G.v.Uzil.Advance.Options.display.get_fullscreen_mode())
	
	G.v.Uzil.Advance.Options.display.set_fullscreen_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#	G.v.Uzil.Advance.Options.display.set_borderless(false)

	get_viewport().gui_embed_subwindows = false
	var new_window = Window.new()
	get_tree().get_root().add_child.call_deferred(new_window)
	
	G.v.Uzil.Advance.Options.display.window_count = 2;
	G.v.Uzil.invoker.inst().once(func():
		print_debug(DisplayServer.get_window_list())
		G.v.Uzil.Advance.Options.display.load_config()
	, 2)
	
	print_debug(AudioServer.get_bus_volume_db(0))
	
#	G.v.Uzil.Advance.Options.audio.set_bus_volume("Master", 0)
	

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

