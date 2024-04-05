@tool
extends Node

## 事件串的事件 觸發器
## 自動尋找
##

## 尋找模式
enum FindBusMode {
	# 即時尋找
	DYNAMIC,
	# 事先尋找
	STATIC,
	# 手動指定
	MANUAL,
	# 以實例key全域尋找
	INST_KEY,
}

# Variable ===================

## 尋找模式
@export
var find_mode : FindBusMode = FindBusMode.DYNAMIC :
	set (value) :
		find_mode = value
		if Engine.is_editor_hint() :
			self.notify_property_list_changed()

## 事件串
@export
var evt_bus_inst_key : String
@export
var evt_bus_node : Node
var _static_evt_bus : Object

## 事件名稱
@export
var evt_key : String

## 事件資料
@export
var evt_data : Dictionary

# GDScript ===================

func _ready () -> void :
	if Engine.is_editor_hint() : return
	self._refresh_mode()

func _validate_property (property: Dictionary) :
	match property.name : 
		"evt_bus_inst_key" :
			match self.find_mode : 
				FindBusMode.INST_KEY:
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		
		"evt_bus_node" :
			match self.find_mode : 
				FindBusMode.MANUAL:
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
	
# Extends ====================

# Interface ==================

# Public =====================

## 觸發 冒泡
func emit () :
	var evt_bus = self._get_evt_bus()
	if evt_bus == null : return
	evt_bus.emit(self.evt_key, self.evt_data.duplicate())

# Private ====================

## 取得 事件串
func _get_evt_bus () :
	var evt_bus_key : String = self.evt_bus_inst_key
	
	match self.find_mode :
		FindBusMode.DYNAMIC :
			var evt_bus_node : Node = self._find_evt_bus_node()
			if evt_bus_node == null : return null
			return evt_bus_node.request_evt_bus()
		
		FindBusMode.STATIC :
			return self._static_evt_bus
		
		FindBusMode.MANUAL :
			if self.evt_bus_node == null : return null
			if self.evt_bus_node.has_method("request_evt_bus") == false : return
			return self.evt_bus_node.request_evt_bus()
		
		FindBusMode.INST_KEY :
			if self.evt_bus.is_empty() : return null
			var evt_bus_mgr = UREQ.acc("Uzil", "evt_bus_mgr")
			return evt_bus_mgr.inst(self.evt_bus)

## 尋找 事件串節點
func _find_evt_bus_node () :
	var cur : Node = self.get_parent()
	while cur != null :
		if cur.has_method("request_evt_bus") :
			return cur
		
		for each in cur.get_children() :
			if each == self : continue
			if each.has_method("request_evt_bus") :
				return each
			
		cur = cur.get_parent()
		
	return null

## 更新 模式
func _refresh_mode () :
	# 清空
	self._static_evt_bus = null
	# 依照尋找模式
	match self.find_mode :
		# 若為 事先尋找
		FindBusMode.STATIC :
			var evt_bus_node : Node = self._find_evt_bus_node()
			if evt_bus_node == null : return null
			self._static_evt_bus = evt_bus_node.get_evt_bus()

