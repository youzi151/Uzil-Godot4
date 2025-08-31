extends Node

# Variable ===================

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

func _input (evt) :
	if evt is InputEventKey :
		var input_evt : InputEventKey = evt
		if input_evt.keycode == KEY_F1 :
			var ids : Array = get_orphan_node_ids()
			G.print("orphan node size : %s" % [ids.size()])
			G.print(ids)
			print_orphan_nodes()

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
