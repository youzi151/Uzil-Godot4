extends Node

# Variable ===================

@export
var button : Button = null :
	set (value) :
		var last := button
		button = value
		if last != null :
			if last.pressed.is_connected(self._on_pressed) :
				last.pressed.disconnect(self._on_pressed)
		if not button.pressed.is_connected(self._on_pressed) :
			button.pressed.connect(self._on_pressed)

@export
var audio_id : String = ""

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	if self.button == null :
		var slf = self
		if slf is Button :
			self.button = slf

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

func _on_pressed () :
	if self.audio_id.is_empty() : return
	var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
	audio_mgr.play(self.audio_id)

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

