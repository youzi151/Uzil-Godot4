extends Node

# Variable ===================

@export
var control : Control = null

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	self.control.focus_mode = Control.FOCUS_NONE

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

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

