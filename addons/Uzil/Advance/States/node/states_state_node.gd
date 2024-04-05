@tool
extends Node

## 設置類型
enum StratSetType {
	# 腳本ID
	SCRIPT_ID,
	# 腳本資源
	SCRIPT_RES,
}

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = ""

## 腳本設置類型
@export var strat_set_type : StratSetType = StratSetType.SCRIPT_ID :
	set (value) : 
		strat_set_type = value
		self.notify_property_list_changed()

## 面板設置 策略
@export var strat_id := ""

## 面板設置 策略
@export var strat_script : GDScript = null

## 資料
@export var data := {}

## 實體
var state = null

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	if Engine.is_editor_hint() : return
	self.request_state()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

func _validate_property (property: Dictionary) :
	match property.name : 
		"strat_id" :
			match self.strat_set_type : 
				StratSetType.SCRIPT_ID :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		"strat_script" :
			match self.strat_set_type : 
				StratSetType.SCRIPT_RES :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR


# Extends ====================

# Public =====================

func request_state () :
	if self.state != null : return self.state
	
	var State = UREQ.acc("Uzil", "Advance.States").State
	match self.strat_set_type :
		StratSetType.SCRIPT_ID :
			self.state = State.new(self.strat_id)
		StratSetType.SCRIPT_RES :
			self.state = State.new(self.strat_script.new())
		
	if self.id == "" :
		self.state.id = self.name
	else :
		self.state.id = self.id
		
	for key in self.data :
		var each = self.data[key]
		if typeof(each) == TYPE_NODE_PATH :
			self.data[key] = self.get_node(each)
	
	self.state.set_data(self.data)
	
	return self.state

# Private ====================

