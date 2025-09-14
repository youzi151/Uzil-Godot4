extends Node

# Variable ===================

@export
var target : Control

@export
var force : float = 10.0

var spring

var is_dragging := false

# GDScript ===================

func _ready () :
	var math = UREQ.acc(&"Uzil:Math")
	self.spring = math.Spring.new()

func _input (_evt) :
	if _evt is InputEventMouseButton : 
		var evt : InputEventMouseButton = _evt
		if evt.pressed :
			self.is_dragging = true
			self.spring.target_value = evt.global_position.x
		else :
			self.is_dragging = false
	elif _evt is InputEventMouseMotion :
		if not self.is_dragging : return
		var evt : InputEventMouseMotion = _evt
		self.spring.target_value = evt.global_position.x
		

func _process (_dt: float) :
	self.spring.process(_dt)
	self.target.global_position.x = self.spring.current_value

# Extends ====================

# Public =====================
