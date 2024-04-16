extends Node

# Variable ===================

@export
var is_auto_load : bool = true

@export
var is_release_current : bool = true

## 下一個要讀取的場景
## 不能直接用PackedScene, 因為這樣會因為資源關連而直接預載. 無法實現一些動態需求.
@export
var next_scene : String = ""

# GDScript ===================

func _init () :
	pass

# Called when the node enters the scene tree for the first time.
func _ready () :
	if self.is_auto_load :
		self.change_scene.call_deferred()
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

func change_scene () :
	var res_info = await UREQ.acc("Uzil", "res").hold(self.next_scene)
	if res_info == null : return
	
	var scene : PackedScene = res_info.res
	var new_scene : Node = scene.instantiate()
	
	var tree := self.get_tree()
	var cur_scene : Node = tree.current_scene
	tree.root.content_scale_size
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
	
	if self.is_release_current :
		cur_scene.queue_free()

# Private ====================

