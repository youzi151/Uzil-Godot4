extends Node

# Variable ===================

@export
var control : Control = null

# GDScript ===================

func _ready () :
	self.control.focus_mode = Control.FOCUS_NONE

# Extends ====================

# Interface ==================

func on_ui_nav_enter () :
	if self.control != null :
		self.control.focus_mode = Control.FOCUS_ALL
		self.control.grab_focus()

func on_ui_nav_exit () :
	if self.control != null :
		self.control.focus_mode = Control.FOCUS_NONE

# Public =====================

# Private ====================

