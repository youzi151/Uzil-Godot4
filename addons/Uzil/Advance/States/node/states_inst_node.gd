@tool
extends Node

# Variable ===================

## 是否註冊
@export var is_reg_to_mgr := true :
	set (value) :
		is_reg_to_mgr = value
		if Engine.is_editor_hint() :
			self.notify_property_list_changed()

@export var inst_key := ""

@export var user : Node = null

## 預設狀態
@export var default_state_id := ""

## 面板設置 狀態列表
@export var states_nodes : Array[Node] = []

## 實體
var inst = null

# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_inst()

func _process (_dt: float) :
	pass

func _validate_property (property: Dictionary) :
	match property.name : 
		"inst_key" :
			if self.is_reg_to_mgr :
				property.usage |= PROPERTY_USAGE_EDITOR
			else :
				property.usage ^= PROPERTY_USAGE_EDITOR

# Extends ====================

# Public =====================
func request_inst () :
	if self.inst != null : return self.inst
	
	if self.is_reg_to_mgr :
		self.inst = UREQ.acc("Uzil", "states_mgr").inst(self.inst_key)
	else :
		var Inst = UREQ.acc("Uzil", "Advance.States").Inst
		self.inst = Inst.new()
	
	self.inst.default_state_id = self.default_state_id
	
	if self.user != null :
		self.inst.set_user(self.user)
	
	# 每個指定Node 取得為 State
	for each in self.states_nodes :
		if each != null and each.has_method("request_state") :
			self.inst.add_state(each.request_state())
	
	return self.inst

# Private ====================
