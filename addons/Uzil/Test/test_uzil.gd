extends Node

## 選擇測試 面板 ######
@export_category("select panel")

## 場景設定
@export
var scenes_config_root : Node

## 測試選擇 面板節點
@export
var select_panel : Node

## 列表容器
@export
var list_container : BoxContainer

## 滾動容器
@export
var scroll_container : ScrollContainer

## 返回按鈕
@export
var back_btn : Button

## 根 測試資料
var root_test_data : Dictionary = {}

## 當前 測試資料(目錄)
var current_test_data_dir : Dictionary = {}
## 當前 子測試節點
var current_sub_test_nodes : Array = []


## 測試場景 ######
@export_category("test scene")

## 測試場景 面板
@export
var test_scene_panel : Node

## 測試場景 容器
@export
var test_scene_container : Node

## 測試場景 標題文字
@export
var test_scene_title : RichTextLabel

## 已讀取的場景
var loaded_scene : Node

func _ready () :
	
	# 取得設定場景
	self.root_test_data = self._get_test_data(self.scenes_config_root)
	
	# 前往首頁
	self.go_test(self.root_test_data)
	
	# 顯示面板
	self.select_panel.visible = true
	self.test_scene_panel.visible = false

func _process (delta: float) :
	
	var vbar = self.scroll_container.get_v_scroll_bar()
	vbar.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE ,Control.PRESET_MODE_KEEP_SIZE)

## 當 首頁 按下
func on_home_btn () :
	# 卸載場景
	if self.loaded_scene != null :
		self.loaded_scene.get_parent().remove_child(self.loaded_scene)
	
	# 切換面板
	self.select_panel.visible = true
	self.test_scene_panel.visible = false

## 當 返回 按下
func on_back_btn () :
	if self.current_test_data_dir == self.root_test_data : return
	if self.current_test_data_dir.parent == null : return
	self.go_test(self.current_test_data_dir.parent)

## 前往 測試 (目錄或場景)
func go_test (test_data: Dictionary) :
	# 若 為 測試場景 則 開啟測試場景
	if test_data.has("scene") :
		self._open_test_scene(test_data)
	
	# 若 為 測試目錄 則 開啟測試目錄
	elif test_data.has("sub_tests") :
		self._open_test_dir(test_data)
		
	# 若有 更上層 的 測試目錄 則
	if test_data.has("parent") and test_data.parent != null :
		# 開啟 返回按鈕
		self.back_btn.visible = true
	# 否則
	else :
		# 關閉 返回按鈕
		self.back_btn.visible = false

## 開啟 測試目錄
func _open_test_dir (test_data: Dictionary) :
	
	# 清除 舊的
	for each in self.current_sub_test_nodes :
		var each_node : Node = each
		self.list_container.remove_child(each_node)
		each_node.queue_free()
	self.current_sub_test_nodes.clear()
	
	# 設置 新的
	self.current_test_data_dir = test_data
	
	# 建構 新的
	for each in test_data.sub_tests :
		var btn_node = self._add_btn(each.node.name, each)
		self.list_container.add_child(btn_node)
		self.current_sub_test_nodes.push_back(btn_node)
	

## 開啟 測試場景
func _open_test_scene (test_data: Dictionary) :
	
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


## 取得 測試資料
func _get_test_data (node: Node) :
	
	# 測試資料
	var test_data := {
		"node" : node
	}
	
	# 若有 腳本方法 : get_scene
	# 視為 測試場景
	if node.has_method("get_scene") :
		
		test_data.scene = node.get_scene()
		
	# 否則 視為 測試分類
	else :
		
		var sub_tests := []
		for each_sub_node in node.get_children():
			var sub_test = self._get_test_data(each_sub_node)
			sub_test.parent = test_data
			sub_tests.push_back(sub_test)
		test_data.sub_tests = sub_tests
	
	return test_data

## 新增 按鈕
func _add_btn (name: String, test_data: Dictionary) :
	# 按鈕
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(300, 50)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	#btn.text = "%s (%s)" % [name, scene.resource_path.get_file().get_basename()]
	btn.text = "%s" % [name]
	btn.pressed.connect(func():
		self.go_test(test_data)
	)
	
	# 容器
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_child(btn)
	
	return margin
