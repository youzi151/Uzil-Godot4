extends Node

## 貼圖按鈕 擴展 顏色變更 
## 
## 讓 TextureButton 在 變更貼圖時, 也能變更顏色
## 使用方法為將此腳本附加到

# Variable ===================

## 目標
@export var target : TextureButton = null

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
	var slf : Node = self
	
	# 若 沒有指定目標 則 找尋 自己 或 父物件
	if self.target == null :
		if slf is TextureButton :
			self.target = (slf as TextureButton)
		else : 
			var next = self.get_parent()
			while next != null :
				if next is TextureButton :
					self.target = next
					break
				next = next.get_parent()
	
	# 抓取 原始顏色
	self.original_color = self.target.modulate
	
	# 向 目標 註冊 事件
	self.target.mouse_entered.connect(self.on_hover)
	self.target.mouse_exited.connect(self.off_hover)
	self.target.button_down.connect(self.on_btn_down)
	self.target.button_up.connect(self.on_btn_up)
	

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

