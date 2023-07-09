extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
#	pass

	var Options = UREQ.acc("Uzil", "Advance.Options")
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
#	print("fullscreen mode : %s" % Options.display.get_fullscreen_mode())
	
	
	Options.display.set_fullscreen_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#	Options.display.set_borderless(false)

	get_viewport().gui_embed_subwindows = false
	var new_window = Window.new()
	get_tree().get_root().add_child.call_deferred(new_window)
	
	Options.display.window_count = 2;
	invoker_mgr.inst().once(func():
		print_debug(DisplayServer.get_window_list())
		Options.display.load_config()
	, 2)
	
	print_debug(AudioServer.get_bus_volume_db(0))
	
#	Options.audio.set_bus_volume("Master", 0)
	

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

