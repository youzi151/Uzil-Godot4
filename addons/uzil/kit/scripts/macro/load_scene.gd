extends Node

# Variable ===================

## 是否自動讀取
@export
var is_auto_load : bool = true

## 是否在讀取下個場景後, 釋放當前場景
@export
var is_release_current : bool = true

## 下一個要讀取的場景
## 不能直接用PackedScene, 因為這樣會因為資源關連而直接預載. 無法實現一些動態需求.
@export
var next_scene_path : String = ""

## 場景 名稱:路徑 表
@export
var name_to_scene_path : Dictionary = {}

# GDScript ===================

func _ready () :
	if self.is_auto_load :
		self.change_scene.call_deferred()

# Extends ====================

# Interface ==================

# Public =====================

## 切換場景
func change_scene () :
	var path : String = self.next_scene_path
	
	# 若 執行命令 有 指定讀取場景
	for each in OS.get_cmdline_args() :
		
		# 指定場景 名稱
		if each.begins_with("--load_scene=") : 
			var scene_name : String = each.trim_prefix("--load_scene=")
			# 若有在 場景名稱:路徑表中 則 指定讀取路徑
			if self.name_to_scene_path.has(scene_name) :
				path = self.name_to_scene_path[scene_name]
				break
		
		# 指定場景 路徑
		elif each.begins_with("--load_scene_path=") : 
			path = each.trim_prefix("--load_scene_path=")
			break
	
	# 讀取 資源
	var res_info = await UREQ.acc(&"Uzil:res").hold(path)
	if res_info == null : return
	
	var scene : PackedScene = res_info.res
	var new_scene : Node = scene.instantiate()
	
	# 加入 場景樹
	var tree := self.get_tree()
	var cur_scene : Node = tree.current_scene
	tree.root.content_scale_size
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
	
	# 釋放 當前場景
	if self.is_release_current :
		cur_scene.queue_free()

# Private ====================
