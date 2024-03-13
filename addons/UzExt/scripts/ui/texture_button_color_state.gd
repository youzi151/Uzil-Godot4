extends Node

## 貼圖按鈕 顏色變更 
## 
## 讓 TextureButton 在 變更貼圖時, 也能變更顏色
## 使用方法為將此腳本附加到 TextureButton 或 子Node 上

# Variable ===================

## 目標
@export var target : TextureButton = null :
	set (value) :
		var last := target
		target = value
		self._target_setup(last, target)

## 普通顏色
@export var normal_color : Color = Color.WHITE
## 停駐顏色
@export var hover_color : Color = Color.WHITE
## 按壓顏色
@export var press_color : Color = Color.GRAY
## 關閉顏色
@export var disabled_color : Color = Color.DARK_GRAY

## 原始顏色
var original_color : Color = Color.TRANSPARENT

## 是否停駐
var _is_hover := false
## 是否按壓
var _is_btn_down := false

# GDScript ===================

func _init () :
	pass

func _ready () :
	self._target_setup(null, self.target)

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
	var to_color : Color = self.normal_color
	if self.target.disabled :
		to_color = self.disabled_color
	elif self._is_btn_down :
		to_color = self.press_color
	elif self._is_hover :
		to_color = self.hover_color
		
	self.target.self_modulate = self.original_color * to_color

# Private ====================

func _target_setup (last_target, new_target) :
	if last_target != null :
		# 向 目標 註冊 事件
		if last_target.mouse_entered.is_connected(self.on_hover) :
			last_target.mouse_entered.disconnect(self.on_hover)
		if last_target.mouse_exited.is_connected(self.off_hover) :
			last_target.mouse_exited.disconnect(self.off_hover)
		if last_target.button_down.is_connected(self.on_btn_down) :
			last_target.button_down.disconnect(self.on_btn_down)
		if last_target.button_up.is_connected(self.on_btn_up) :
			last_target.button_up.disconnect(self.on_btn_up)
	
	if new_target != null :
		# 抓取 原始顏色
		self.original_color = new_target.modulate
		
		# 向 目標 註冊 事件
		if not new_target.mouse_entered.is_connected(self.on_hover) :
			new_target.mouse_entered.connect(self.on_hover)
		if not new_target.mouse_exited.is_connected(self.off_hover) :
			new_target.mouse_exited.connect(self.off_hover)
		if not new_target.button_down.is_connected(self.on_btn_down) :
			new_target.button_down.connect(self.on_btn_down)
		if not new_target.button_up.is_connected(self.on_btn_up) :
			new_target.button_up.connect(self.on_btn_up)
