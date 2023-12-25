extends Node

# Variable ===================

@export var control_np : NodePath = ""
var _control : Control = null

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	if self.control_np != null :
		self._control = self.get_node(self.control_np)
		if self._control is Control :
			self._control.focus_mode = Control.FOCUS_NONE

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

func on_ui_nav_enter () :
	if self._control != null :
		self._control.focus_mode = Control.FOCUS_ALL
		self._control.grab_focus()

func on_ui_nav_exit () :
	if self._control != null :
		self._control.focus_mode = Control.FOCUS_NONE

# Public =====================

# Private ====================

