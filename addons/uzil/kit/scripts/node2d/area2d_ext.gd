extends Area2D

# Variable ===================

signal on_body_shape_entered

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	self.body_shape_entered.connect(self._on_body_shape_entered)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

func _on_body_shape_entered (body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) :
	if body in self.get_overlapping_bodies() :
		var shape = self.shape_owner_get_owner(self.shape_find_owner(local_shape_index))
		self.on_body_shape_entered.emit({
			"body_rid": body_rid,
			"body": body,
			"body_shape_index": body_shape_index,
			"local_shape_index": local_shape_index,
			"shape": shape,
		})
	
	
