
# Variable ===================

# GDScript ===================

func _init () :
	var scope = UREQ.scope("test")
	var module_C = scope.access("C")
	var module_D = scope.access("D")
	G.print("init module b")

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

