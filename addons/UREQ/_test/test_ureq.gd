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
	})
	
	scope.bind("C", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_c.gd"))
	
	scope.bind("D", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_d.gd"), {
		"requires" : ["C", "wait_sec"]
	})
	
	scope.bind("wait_sec", 
		func():
			var timer = self.get_tree().create_timer(3)
			await timer.timeout
			print("wait_done")
			return 0
			,
		{
			"is_async" : true
		}
	)
	
	print("scope.accync(\"A\")")
	await scope.accync("A")
	print("A loaded")

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

