extends Node

# Variable ===================

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	
	var UREQ = G.UREQ
	var group = UREQ.group("test")
	
	group.bind("A", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_a.gd"), {
		"requires" : ["B"]
	})
	
	group.bind("B", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_b.gd"), {
		"requires" : ["C", "D"],
		"is_lazy" : false,
	})
	
	group.bind("C", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_c.gd"))
	
	group.bind("D", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_d.gd"), {
		"requires" : ["C"]
	})
	
	group.install()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

