extends Node

## PageCard.TargetPrefab_Node 頁面卡 目標預製物件 節點
## 
## 作為Card的target, 當啟用時建立/顯示Prefab的實例, 關閉時釋放或隱藏Prefab的實例.
##

enum LifeMode {
	# 動態
	DYNAMIC,
	# 靜態
	STATIC,
	# 被動
	PASSTIVE,
}

# Variable ===================

## 生命模式 [br]
## 動態Dynamic : [br]
##   被呼叫card_active時, 會即時以Prefab建立實體到Container中. [br]
##   被呼叫card_deactive時, 會將建立的實體釋放掉. [br]
## 靜態Static :  [br]
##   會在_ready時事先以Prefab建立實體. [br]
##   被呼叫card_active時, 會將建立的實體開啟(visible與process_mode). [br]
##   被呼叫card_deactive時, 會將建立的實體關閉(visible與process_mode). [br]
## 被動Passtive : [br]
##   類似Static, 但不會在_ready時就是先建立, 而使等到card_active時若不存在才建立實體. [br]
@export
var life_mode : LifeMode = LifeMode.DYNAMIC :
	set (value) :
		var last : LifeMode = life_mode
		life_mode = value
		self._refresh_mode(last, life_mode)

## 是否 應用顯示至容器
@export
var is_effect_container_visible : bool = true

## 容器
@export
var container : Node = null

## 以prefab建立的實例的meta中指定要分離的節點 與 對應 子容器.
## 會以該 unpack_id 在 以prefab建立的實例 的 meta 中 找 對應子節點,
## 並設置到 unpack_id_to_container 中對應的子容器.
@export
var unpack_id_to_container : Dictionary = {}

## 預製物件
@export
var prefabs : Array[PackedScene] = []

## 已建立的
var _existed : Array[Node] = []

# GDScript ===================

func _ready () :
	if self.container == null :
		self.container = self
	
	match self.life_mode :
		LifeMode.STATIC :
			self._request_existed()

# Interface ==================

## 啟用卡片
func card_active (_options: Dictionary) :
	
	# 是否顯示
	var visible := true
	if "visible" in _options :
		visible = _options["visible"]
	
	# 若為 動態 或 被動 則 請求
	match self.life_mode :
		LifeMode.DYNAMIC, LifeMode.PASSTIVE :
			self._request_existed(_options)
	
	# 顯示
	self._show_existed(visible)
	
	# 若 需要應用顯示 至 容器
	if self.is_effect_container_visible :
		self.container.visible = visible

## 關閉卡片
func card_deactive (_options: Dictionary) :
	match self.life_mode :
		LifeMode.DYNAMIC :
			self._release_existed()
		LifeMode.STATIC :
			self._show_existed(false)
		LifeMode.PASSTIVE :
			self._show_existed(false)
	
	if self.is_effect_container_visible :
		self.container.visible = false

# Public =====================

# Private ====================

## 請求/建立
func _request_existed (_options := {}) :
	if not self._existed.is_empty() : return
	
	var node_path_to_container : Dictionary = {}
	
	for each in self.prefabs :
		
		var new_one : Node = each.instantiate()
		
		# 加入 已建立列表
		self._existed.push_back(new_one)
		# 移交 給 容器
		self.container.add_child(new_one)
		
		# 每個 解包的meta 對應 容器
		for unpack_id in self.unpack_id_to_container.keys() :
			# 若 該實例中 沒有該meta 則 忽略
			if not new_one.has_meta(unpack_id) : continue
			
			# 取得 節點路徑或列表
			var node_path_or_list = new_one.get_meta(unpack_id)
			
			# 取得 對應容器
			var container : Node = null
			var container_path : NodePath = self.unpack_id_to_container[unpack_id]
			if container_path in node_path_to_container :
				container = node_path_to_container[container_path]
			else :
				container = self.get_node(container_path)
				node_path_to_container[container_path] = container
			
			# 要處理的列表
			var list : Array = []
			# 若 為 節點路徑
			if node_path_or_list is NodePath : 
				list.push_back(node_path_or_list)
			# 若 為 列表
			elif node_path_or_list is Array :
				list = node_path_or_list
			
			# 每個 節點路徑 在 要處理的列表 中
			for node_path in list :
				# 從 實例 取得 子節點
				var node : Node = new_one.get_node(node_path)
				# 額外加入已建立列表中
				self._existed.push_back(node)
				# 移交 給 容器
				node.get_parent().remove_child(node)
				container.add_child(node)
			
		

## 釋放
func _release_existed () :
	if self._existed.is_empty() : return
	for each in self._existed :
		var parent : Node = each.get_parent()
		if parent != null :
			each.get_parent().remove_child(each)
		each.queue_free()
	self._existed.clear()

## 顯示/隱藏
func _show_existed (is_show := true) :
	for each in self._existed :
		if is_show :
			each.visible = true
			each.process_mode = Node.PROCESS_MODE_INHERIT
		else :
			each.visible = false
			each.process_mode = Node.PROCESS_MODE_DISABLED

## 當 更新模式
func _refresh_mode (last_mode: int, next_mode: int) :
	if last_mode == next_mode : return
	match last_mode :
		LifeMode.DYNAMIC :
			self._release_existed()
	match next_mode :
		LifeMode.STATIC :
			self._request_existed()
