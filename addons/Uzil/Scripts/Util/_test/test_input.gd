extends Uzil_Test_Base

# Variable ===================

var util

# Extends ====================

func test_ready () :
	self.util = UREQ.acc("Uzil", "Util")
	
#	self.test_print(self.util.input.keycode.name_to_gdkeys("key.a"))
#	self.test_print(self.util.input.keycode.name_to_keycode("joy.0.a"))
	self.test_print(self.util.input.keycode.device_type_to_keycode_infos)
	

func test_process (_delta) :
	self.test_print_clear()
#	var key = self.util.input.keycode.name_to_keycode("key.a")
#	var key = self.util.input.keycode.name_to_keycode("joy.0.a")
#	var key = self.util.input.keycode.name_to_keycode("mouse.lmb")
	var key = self.util.input.keycode.name_to_keycode("touch")
	
#	self.test_print(Input.is_joy_button_pressed(0, JOY_BUTTON_A))
	self.test_print("key[%s] : %s" % [key, self.util.input.get_input(key)])
# Public =====================
