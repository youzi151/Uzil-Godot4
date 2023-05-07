extends Node

## PageCard.Page 頁面卡 卡片
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = "" :
	get :
		if _id == "" : return self.name
		else : return self._id
	set (value) :
		self._id = value
var _id : String = ""

## 目標物件
@export var target_nodepath : NodePath = ""
var _target_node : Node = null

# GDScript ===================

func _ready () :
	self._target_node = self.get_node(self.target_nodepath)

func _process (_dt) :
	pass

# Public =====================

## 是否啟用
func is_active () -> bool :
	if self._target_node == null : return false
	if "visible" in self._target_node :
		return self._target_node.visible
	return false

func active () :
	if self._target_node == null : return
	if "visible" in self._target_node :
		self._target_node.visible = true
	self._target_node.process_mode = Node.PROCESS_MODE_INHERIT

func deactive () :
	if self._target_node == null : return
	if "visible" in self._target_node :
		self._target_node.visible = false
	self._target_node.process_mode = Node.PROCESS_MODE_DISABLED

# Private ====================
