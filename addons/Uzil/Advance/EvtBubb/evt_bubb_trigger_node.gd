extends Node

# Variable ===================


## 事件名稱
@export
var evt_name : String

## 事件資料
@export
var evt_data : Dictionary

## 觸發 節點
@export
var handler_node : Node

# GDScript ===================

func _ready () :
	pass

func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 觸發 冒泡
func trigger () :
	
	# 建立 事件
	var Evt = UREQ.acc("Uzil", "Advance.EvtBubb").Evt
	var evt = Evt.new()
	
	evt.name = self.evt_name
	evt.data = self.evt_data.duplicate()
	
	var handler_node : Node = self.handler_node
	if handler_node == null :
		handler_node = self._find_next_handler_node()
	
	if handler_node != null :
		handler_node.bubbling(evt)
	

# Private ====================

func _find_next_handler_node () :
	
	var GDScriptUtil = UREQ.acc("Uzil", "Util").gdscript
	var HandlerNode = UREQ.acc("Uzil", "Advance.EvtBubb").HandlerNode
	
	var cur : Node = self.get_parent()
	while cur != null :
		if GDScriptUtil.is_extends_of(cur.get_script(), HandlerNode) :
			return cur
		
		for each in cur.get_children() :
			if each == self : continue
			if GDScriptUtil.is_extends_of(each.get_script(), HandlerNode) :
				return each
			
		cur = cur.get_parent()
		
	return null
