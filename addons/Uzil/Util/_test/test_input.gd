extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

var util

var aaa = 2000

# GDScript====================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_input")
	
	self.util = UREQ.acc(&"Uzil:Util")
	
#	G.print(self.util.input.keycode.name_to_gdkeys("key.a"))
#	G.print(self.util.input.keycode.name_to_keycode("joy.0.a"))
	G.print(self.util.input.keycode.device_type_to_keycode_infos)
	

func _process (_delta: float) :
	aaa -= _delta
	if aaa < 0 : 
		aaa = 2000
		return
	self.test()

func _exit_tree () :
	G.off_print("test_input")

# Extends ====================

# Public =====================

func test () :
#	var key = self.util.input.keycode.name_to_keycode("key.a")
#	var key = self.util.input.keycode.name_to_keycode("joy.0.a")
	var key = self.util.input.keycode.name_to_keycode("mouse.lmb")
#	var key = self.util.input.keycode.name_to_keycode("touch")
	
#	G.print(Input.is_joy_button_pressed(0, JOY_BUTTON_A))
	G.print("key[%s] : %s" % [key, self.util.input.get_input(key)])
