extends Node

@export_category("select panel")

@export
var scenes_config_root_np : NodePath
var scenes_config_root : Node

@export
var select_panel_np : NodePath
var select_panel : Node

@export
var list_container_np : NodePath
var list_container : BoxContainer

@export
var scroll_container_np : NodePath
var scroll_container : ScrollContainer

var scenes : Array[Dictionary] = []


@export_category("test scene")

@export
var test_scene_panel_np : NodePath
var test_scene_panel : Node

@export
var test_scene_container_np : NodePath
var test_scene_container : Node

@export
var test_scene_title_np : NodePath
var test_scene_title : RichTextLabel

var loaded_scene : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# 綁定
	self.list_container = self.get_node(self.list_container_np)
	self.scroll_container = self.get_node(self.scroll_container_np)
	
	self.select_panel = self.get_node(self.select_panel_np)
	self.scenes_config_root = self.get_node(self.scenes_config_root_np)
	self.test_scene_panel = self.get_node(self.test_scene_panel_np)
	self.test_scene_title = self.get_node(self.test_scene_title_np)
	self.test_scene_container = self.get_node(self.test_scene_container_np)
	
	# 取得設定場景
	self._get_scene_in_childs(self.scenes_config_root)
	
	# 新增選項
	for each in self.scenes :
		var node : Node = each.node
		var scene : PackedScene = each.scene
		
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(300, 50)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		#btn.text = "%s (%s)" % [node.name, scene.resource_path.get_file().get_basename()]
		btn.text = "%s" % [node.name]
		btn.pressed.connect(func () :
			self.go_test(each)
		)
		
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_child(btn)
			
		self.list_container.add_child(margin)
	
	# 顯示面板
	self.select_panel.visible = true
	self.test_scene_panel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var vbar = self.scroll_container.get_v_scroll_bar()
	vbar.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE ,Control.PRESET_MODE_KEEP_SIZE)

func go_test (test_data : Dictionary) :
	var scene : PackedScene = test_data.scene
	var node : Node = test_data.node
	G.print(scene.resource_path)
	
	# 標題
	#var title_str = scene.resource_path.get_file().get_basename().replace("test_", "")
	var title_str = "%s   (%s)" % [node.name, scene.resource_path.get_file().get_basename()]
	self.test_scene_title.text = title_str
	
	# 讀取場景
	self.loaded_scene = scene.instantiate()
	self.test_scene_container.add_child(self.loaded_scene)
	
	# 切換面板
	self.select_panel.visible = false
	self.test_scene_panel.visible = true
	
	
func on_back_btn () :
	# 卸載場景
	if self.loaded_scene != null :
		self.loaded_scene.get_parent().remove_child(self.loaded_scene)
	
	# 切換面板
	self.select_panel.visible = true
	self.test_scene_panel.visible = false
		

func _get_scene_in_childs (node : Node) :
	for each in node.get_children():
		if each.has_method("get_scene") :
			self.scenes.push_back({
				"node" : each,
				"scene" : each.get_scene(),
			})
		self._get_scene_in_childs(each)
	
