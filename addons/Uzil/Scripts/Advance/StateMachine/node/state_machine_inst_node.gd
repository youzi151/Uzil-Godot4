extends Node

# Variable ===================

@export var inst_key := "_none"

@export var user : NodePath = ""

## 預設狀態
@export var default_state_id := ""

## 面板設置 狀態列表
@export var states_nodepath : Array[NodePath] = []

## 實體
var inst = null

# GDScript ===================

func _init () :
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	self.request_inst()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass

# Extends ====================

# Public =====================
func request_inst () :
	if self.inst != null : return self.inst
	
	if self.inst_key == "_none" :
		self.inst = UREQ.acc("Uzil", "Advance.StateMachine").Inst.new()
	else :
		self.inst = UREQ.acc("Uzil", "states_mgr").inst(self.inst_key)
	
	self.inst.default_state_id = self.default_state_id
	
	if not self.user.is_empty() :
		var _user = self.get_node(self.user)
		if _user != null :
			self.inst.set_user(self.get_node(self.user))
	
	# 每個指定Node路徑 取得為 Node
	for each in self.states_nodepath :
		var node : Node = self.get_node(each)
		if node != null :
			self.inst.add_state(node.request_state())
	
	return self.inst

# Private ====================
