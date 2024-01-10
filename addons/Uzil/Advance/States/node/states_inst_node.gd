extends Node

# Variable ===================

@export var inst_key := "_none"

@export var user : Node = null

## 預設狀態
@export var default_state_id := ""

## 面板設置 狀態列表
@export var states_nodes : Array[Node] = []

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
		self.inst = UREQ.acc("Uzil", "Advance.States").Inst.new()
	else :
		self.inst = UREQ.acc("Uzil", "states_mgr").inst(self.inst_key)
	
	self.inst.default_state_id = self.default_state_id
	
	if self.user != null :
		self.inst.set_user(self.user)
	
	# 每個指定Node 取得為 State
	for each in self.states_nodes :
		if each != null and each.has_method("request_state") :
			self.inst.add_state(each.request_state())
	
	return self.inst

# Private ====================
