extends Node

# Variable ===================

@export
var target_node : Node = null

@export
var bind_route : String = ""

# GDScript ===================

func _ready () :
	var route : StringName = StringName(self.bind_route)
	var parsed_route : PackedStringArray = UREQ.parse_route(self.bind_route)
	if parsed_route.size() == 2 :
		var scope : StringName = StringName(parsed_route[0])
		var key : StringName = StringName(parsed_route[1])
		UREQ.bind(scope, key, self.target_node)
		self.target_node.tree_exited.connect(func():
			UREQ.unbind(route)
		, CONNECT_ONE_SHOT)
	

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
