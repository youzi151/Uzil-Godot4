@tool
extends Node

## 設置類型
enum HandlerSetType {
	# 腳本ID
	SCRIPT_ID,
	# 腳本資源
	SCRIPT_RES,
}

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export
var id : String = ""

## 轉場
@export
var transition_ids : Array[String] = []

## 腳本設置類型
@export
var handler_set_type : HandlerSetType = HandlerSetType.SCRIPT_ID :
	set (value) : 
		handler_set_type = value
		self.notify_property_list_changed()

## 面板設置 處理器
@export
var handler_ids : Array[String] = []

## 面板設置 處理器 (需注意會被preload)
@export
var handler_scripts : Array[GDScript] = []

## 是否自動轉換NodePath
@export
var is_auto_convert_node_path : bool = true

## 資料
@export
var data : Dictionary = {}

## 實體
var state = null

# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_state()

func _validate_property (property: Dictionary) :
	match property.name : 
		"handler_ids" :
			match self.handler_set_type : 
				HandlerSetType.SCRIPT_ID :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		"handler_scripts" :
			match self.handler_set_type : 
				HandlerSetType.SCRIPT_RES :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR


# Extends ====================

# Public =====================

func request_state () :
	
	if self.state != null : 
		return self.state
	
	var State = UREQ.acc(&"Uzil:Advance.States").State
	self.state = State.new()
	
	var handlers = null
	match self.handler_set_type :
		HandlerSetType.SCRIPT_ID :
			handlers = self.handler_ids
		HandlerSetType.SCRIPT_RES :
			var paths := []
			for each: GDScript in self.handler_scripts :
				paths.push_back(each.resource_path)
			handlers = paths
		
	if self.id == "" :
		self.state.id = self.name
	else :
		self.state.id = self.id
	
	# 建立一份新的, 避免在特定情況出現問題 :
	# 若此腳本的節點在PackedScene中, 可能會在instantiate後, 
	# 因為改動data中的資料, 影響到PackedScene中的此腳本節點的參數 (可從PackedScene._bundled看出)
	# 導致後續instantiate出來的實例中使用到同一份data. 
	# (可能是傳參考而非複製?)
	var new_data : Dictionary = {}
	
	if self.is_auto_convert_node_path :
		new_data = UREQ.acc(&"Uzil:Util").node.convert_node_path_to_node_in_dict(self, self.data)
	else :
		new_data = self.data.duplicate()
	
	self.state.set_dict({
		"handlers": handlers,
		"transitions": self.transition_ids,
		"data": new_data,
	})
	
	return self.state

# Private ====================
