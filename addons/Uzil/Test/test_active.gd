extends Node

@export
var active_target : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.active_target != null :
		self.active_target.active = true
		self.active_target._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass
