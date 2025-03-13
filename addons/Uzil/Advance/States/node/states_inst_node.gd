@tool
extends Node

# Variable ===================

## 是否註冊至管理
@export var is_reg_to_mgr := true :
	set (value) :
		is_reg_to_mgr = value
		if Engine.is_editor_hint() :
			self.notify_property_list_changed()

## 實例Key
@export var inst_key := ""

## 預設狀態
@export var default_state_id := ""

## 面板設置 狀態列表
@export var state_nodes : Array[Node] = []

## 面板設置 轉場列表
@export var transition_nodes : Array[Node] = []

## 面板設置 條件列表
@export var condition_nodes : Array[Node] = []

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
		self.inst = UREQ.acc(&"Uzil:states_mgr").inst(self.inst_key)
	else :
		var Inst = UREQ.acc(&"Uzil:Advance.States").Inst
		self.inst = Inst.new()
	
	self.inst.default_state_id = self.default_state_id
	
	# 每個指定Node 取得為 狀態
	for each in self.state_nodes :
		if each != null and each.has_method("request_state") :
			self.inst.add_state(each.request_state())
	
	# 每個指定Node 取得為 轉場
	for each in self.transition_nodes :
		if each != null and each.has_method("request_transition") :
			self.inst.add_transition(each.request_transition())
	
	# 每個指定Node 取得為 條件
	for each in self.condition_nodes :
		if each != null and each.has_method("request_condition") :
			self.inst.add_condition(each.request_condition())
	
	return self.inst

# Private ====================
