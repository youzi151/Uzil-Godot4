extends Node

# Variable ===================

@export
var is_enabled : bool = false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	var options = UREQ.acc(&"Uzil:options")
	self.get_tree().root.size_changed.connect(func():
		if not self.is_enabled : return
		options.display.set_window_size(options.display.get_window_size("", false))
	)
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
