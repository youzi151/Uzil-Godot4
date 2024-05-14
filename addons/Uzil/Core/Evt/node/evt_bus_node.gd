@tool
extends Node

## 事件串 節點
## 
## 主要提供觸發器方便取得 全域或本地的事件串
##

## 事件串 實例模式
enum EvtBusInstMode {
	# 本地
	LOCAL,
	# 全域key
	INST_KEY,
}


# Variable ===================

## 實例模式
@export
var mode : EvtBusInstMode = EvtBusInstMode.LOCAL :
	set (value) :
		mode = value
		if Engine.is_editor_hint() :
			self.notify_property_list_changed()
		else :
			self._refresh_mode()

## 實例Key
@export
var evt_bus_inst_key : String

## 本地實例
var _evt_bus : Object

# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self._refresh_mode()

func _validate_property (property: Dictionary) :
	match property.name : 
		"evt_bus_inst_key" :
			match self.mode : 
				EvtBusInstMode.INST_KEY:
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		


# Extends ====================

# Interface ==================

# Public =====================

func request_evt_bus () :
	match self.mode :
		EvtBusInstMode.LOCAL :
			if self._evt_bus == null : 
				var Bus = UREQ.acc(&"Uzil:Core.Evt").Bus
				self._evt_bus = Bus.new()
			return self._evt_bus
			
		EvtBusInstMode.INST_KEY :
			var evt_bus_mgr = UREQ.acc(&"Uzil:evt_bus_mgr")
			return evt_bus_mgr.inst(self.evt_bus)

func _refresh_mode () : 
	if self.mode == EvtBusInstMode.LOCAL :
		self.request_evt_bus()
	else :
		self._evt_bus = null
