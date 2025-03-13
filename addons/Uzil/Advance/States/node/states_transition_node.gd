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

## 下個狀態
@export
var to_state : String = ""

## 條件
@export
var condition_ids : Array[String] = []
## 條件
@export_multiline
var condition_exp : String = ""


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
var transition = null

# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_transition()

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

func request_transition () :
	
	if self.transition != null : 
		return self.transition
	
	var Transition = UREQ.acc(&"Uzil:Advance.States").Transition
	self.transition = Transition.new()
	
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
		self.transition.id = self.name
	else :
		self.transition.id = self.id
	
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
	
	self.transition.set_dict({
		"to_state": self.to_state,
		"condition_exp": self.condition_exp,
		"conditions": self.condition_ids,
		"handlers": handlers,
		"data": new_data,
	})
	
	return self.transition

# Private ====================
