extends Node

## 修正 用滑鼠模擬觸碰 時 的 觸碰延遲問題

# Variable ===================

signal on_mouse_down

signal on_mouse_up

var global_position : Vector2

var drag_offset : Vector2

var is_pressed : bool = false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

func _input (event) :
	if event is InputEventMouseButton : 
		if event.button_index == MOUSE_BUTTON_LEFT :
			if event.is_pressed() :
				self.on_mouse_down.emit()
				self.is_pressed = true
			else :
				self.on_mouse_up.emit()
				self.is_pressed = false
		self.global_position = event.global_position
		
	elif event is InputEventMouseMotion :
		if self.is_dragging :
			self.input_pos = event.global_position
			if not self.is_got_drag_offset :
				self.drag_offset = event.global_position - self.global_position
				self.is_got_drag_offset = true
	else :
		return
	
	self.global_position = event.global_position

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
