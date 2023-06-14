extends Uzil_Test_Base

# Variable ===================

var util

# Extends ====================

func test_ready () :
	self.util = UREQ.access_g("Uzil", "Util")
	
	print(self.util.input.keycode.name_to_gdkeys("key.a"))
	print(self.util.input.keycode.device_type_to_keycode_infos)
	

func test_process (_delta) :
	var key = self.util.input.keycode.name_to_keycode("key.a")
	
#	print(Input.is_joy_button_pressed(0, JOY_BUTTON_A))
	print(self.util.input.get_input(key))

# Public =====================
