extends Node

# Variable ===================

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	
	var UREQ = G.UREQ
	var scope = UREQ.scope("test")
	
	scope.bind("A", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_a.gd"), {
		"requires" : ["B"]
	})
	
	scope.bind("B", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_b.gd"), {
		"requires" : ["C", "D"],
		"is_lazy" : false,
	})
	
	scope.bind("C", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_c.gd"))
	
	scope.bind("D", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_d.gd"), {
		"requires" : ["C"]
	})
	
	scope.install()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

