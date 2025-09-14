extends Node

# Variable ===================

@export
var target : Control
var target_pos : float = 0

@export
var force : float = 10.0

var velocity : float = 0.0

@export
var player : Control

var pid_ctrlr

# GDScript ===================

func _ready () :
	var math = UREQ.acc(&"Uzil:Math")
	self.pid_ctrlr = math.PIDCtrlr.new(1.0, 0.5, 0.8)
	self.pid_ctrlr.set_integral_limit(50.0)

func _input (_evt) :
	if not _evt is InputEventMouseButton : return
	var evt : InputEventMouseButton = _evt
	self.target.global_position.x = evt.global_position.x

func _process (_dt: float) :
	var ctrl_signal : float = self.pid_ctrlr.calculate(self.target.position.x, self.player.position.x, _dt)
	G.print("ctrl_signal: %s" % [ctrl_signal])
	
	self.velocity += self.force * _dt * ctrl_signal
	self.player.position.x += self.velocity * _dt

# Extends ====================

# Public =====================
