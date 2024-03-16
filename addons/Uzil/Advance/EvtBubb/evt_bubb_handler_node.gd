@tool
extends Node

enum BubblingMode {
	STOP,
	DYNAMIC,
	STATIC,
	MANUAL,
}

# Variable ===================

## 執行內容目標
@export
var target : Node

## 模式
@export
var bubbling_mode : BubblingMode = BubblingMode.STOP :
	set (value) :
		bubbling_mode = value
		
		if Engine.is_editor_hint() : 
			self.notify_property_list_changed()
			return
		
		self._refresh_bubbling_mode()

## 後續處理者
@export
var next_handler_node : Node


## 標籤
@export
var tags : Array[String] = []

## 覆寫資料
@export
var override_data : Dictionary = {}


## 處理者本體
var _handler : Object


# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_handler()

func _validate_property (property: Dictionary) :
	match property.name : 
		"next_handler_node" :
			match self.bubbling_mode : 
				BubblingMode.MANUAL:
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR

# Extends ====================

# Interface ==================

# Public =====================

## 請求 處理者
func request_handler () :
	# 若 存在 則 取用
	if self._handler != null :
		return self._handler
	
	# 否則 建立
	var Handler = UREQ.acc("Uzil", "Advance.EvtBubb").Handler
	self._handler = Handler.new()
	
	self._handler.handle_fn = self._handle
	
	self._refresh_bubbling_mode()

## 冒泡
func bubbling (evt) :
	var handler = self.request_handler()
	handler.bubbling(evt)

# Private ====================

func _handle (evt) :
	(evt.data as Dictionary).merge(self.override_data, true)
	if self.target != null :
		self.target.on_bubbling(evt)

func _empty () :
	return null

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

func _find_next_handler () :
	var next_handler_node = self._find_next_handler_node()
	if next_handler_node != null :
		return next_handler_node.request_handler()

func _refresh_bubbling_mode () :
	if self._handler == null : return
	self._handler.next = null
	self._handler.get_next_fn = self._empty
	match self.bubbling_mode :
		BubblingMode.MANUAL :
			if self.next_handler_node != null :
				self._handler.next = self.next_handler_node.request_handler()
		BubblingMode.STATIC :
			var handler_node : Node = self._find_next_handler_node()
			if handler_node != null :
				self._handler.next = handler_node.request_handler()
		BubblingMode.DYNAMIC :
			self._handler.get_next_fn = self._find_next_handler
