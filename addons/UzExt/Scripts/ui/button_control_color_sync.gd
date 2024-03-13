@tool
extends Node

## 按鈕 顏色同步
## 
## 讓 Button 在 變更狀態時, 可以對相應的targets也應用顏色變化
## 

# Variable ===================

## 目標
@export var button : Button = null

@export var targets : Array[Control] = []

## 是否停駐
var _is_hover := false
## 是否按壓
var _is_btn_down := false
## 是否停用
var _is_disabled := false

# GDScript ===================

func _init () :
	pass

func _ready () :
	if self.button == null : return
	
	if not Engine.is_editor_hint() :
		# 向 目標 註冊 事件
		self.button.mouse_entered.connect(self.on_hover)
		self.button.mouse_exited.connect(self.off_hover)
		self.button.button_down.connect(self.on_btn_down)
		self.button.button_up.connect(self.on_btn_up)

func _process (_dt) :
	if self.button == null : return
	
	var is_update : bool = false
	
	if self._is_disabled != self.button.disabled :
		self._is_disabled = self.button.disabled
		is_update = true
	
	if is_update :
		self.update_color()

# Extends ====================

# Public =====================

func on_hover () :
	self._is_hover = true
	self.update_color()

func off_hover () :
	self._is_hover = false
	self.update_color()

func on_btn_down () :
	self._is_btn_down = true
	self.update_color()

func on_btn_up () :
	self._is_btn_down = false
	self.update_color()
	
func update_color () :
	var to_color : Color = self.button.get_theme_color("icon_normal_color")
	if self.button.disabled :
		to_color = self.button.get_theme_color("icon_disabled_color")
	elif self._is_btn_down :
		to_color = self.button.get_theme_color("icon_pressed_color")
	elif self._is_hover :
		to_color = self.button.get_theme_color("icon_hover_color")
	
	for each in self.targets :
		each.modulate = to_color

# Private ====================

