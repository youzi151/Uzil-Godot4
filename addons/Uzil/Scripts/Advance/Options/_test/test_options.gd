extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
#	pass

	var options = UREQ.acc("Uzil", "options")
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
#	print("fullscreen mode : %s" % Options.display.get_fullscreen_mode())
	
	options.display.set_fullscreen_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#	options.display.set_borderless(false)

	get_viewport().gui_embed_subwindows = false
	var new_window = Window.new()
	get_tree().get_root().add_child.call_deferred(new_window)
	
	options.display.window_count = 2;
	invoker_mgr.inst().once(func():
		print_debug(DisplayServer.get_window_list())
		options.display.load_config()
	, 2000)
	
	print_debug(AudioServer.get_bus_volume_db(0))
	
#	Options.audio.set_bus_volume("Master", 0)
	

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

