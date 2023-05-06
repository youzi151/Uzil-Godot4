extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready () :
	print(G.v.Uzil.Util.input.keycode.name_to_gdkeys("key.a"))
	print(G.v.Uzil.Util.input.keycode.device_type_to_keycode_infos)
	

func test_process (_delta) :
	var key = G.v.Uzil.Util.input.keycode.name_to_keycode("key.a")
	
#	print(Input.is_joy_button_pressed(0, JOY_BUTTON_A))
	print(G.v.Uzil.Util.input.get_input(key))

# Public =====================
