extends Node

# Variable ===================

var _integrate_fn_list : Array = []

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

func _integrate_forces (state: PhysicsDirectBodyState2D) :
	for each in self._integrate_fn_list :
		each.call(state)
	self._integrate_fn_list.clear()

# Extends ====================

# Interface ==================

# Public =====================

func do_integrate_forces (fn: Callable) :
	self._integrate_fn_list.push_back(fn)
	var tree = self.get_tree()
	await tree.physics_frame
	await tree.physics_frame

# Private ====================
