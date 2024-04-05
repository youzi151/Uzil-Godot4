@tool
extends Node

## 貼圖按鈕 點擊遮罩設置器
## 
## 設置 從 貼圖 或 節點 自動設置 貼圖按鈕的點擊遮罩
## 需注意:若使用AtlasTexture, 當前版本可能會有無法考量margin的問題, 
## 因此輸出貼圖時, 不要使用Trim來將切成region與margin, 僅region即可.
##

## 設置來源
enum TextureSetMode {
	BUTTON_SELF, TEXTURE, NODE
}

# Variable ===================

## 是否啟用
@export
var is_enabled : bool = true

## 目標 貼圖按鈕
@export
var texture_button : TextureButton = null :
	set (value) :
		texture_button = value
		if Engine.is_editor_hint() : return
		self.refresh()

## 設置模式
@export
var mode : TextureSetMode = TextureSetMode.BUTTON_SELF :
	set (value) :
		mode = value
		self.notify_property_list_changed()

## 貼圖模式 的 目標貼圖
@export
var target_texture : Texture2D = null :
	set (value) :
		target_texture = value
		if Engine.is_editor_hint() : return
		self.refresh()

var _last_texture : Texture2D = null

## 節點模式 的 目標節點
@export
var from_node : Node = null :
	set (value) :
		var last : Node = from_node
		from_node = value
		if Engine.is_editor_hint() : return
		self.refresh()

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	if Engine.is_editor_hint() : return
	self.refresh()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	if Engine.is_editor_hint() : return
	
	if self.mode == TextureSetMode.NODE :
		if self._last_texture != self._get_tex_from_node() :
			self.refresh()

func _validate_property (property: Dictionary) :
	match property.name : 
		"target_texture" :
			match self.mode : 
				TextureSetMode.TEXTURE :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		"from_node" :
			match self.mode : 
				TextureSetMode.NODE :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR

# Extends ====================

# Interface ==================

# Public =====================

func refresh () :
	if not self.is_enabled : return
	if self.texture_button == null : return
	var bitmap : BitMap = null
	
	var tex : Texture2D = null
	
	match self.mode :
		TextureSetMode.BUTTON_SELF :
			tex = self.texture_button.texture_normal
		TextureSetMode.TEXTURE :
			if self.target_texture != null :
				tex = self.target_texture
		TextureSetMode.NODE :
			if self.from_node != null :
				tex = self._get_tex_from_node()
					
	if tex != null :
		bitmap = BitMap.new()
		bitmap.create_from_image_alpha(tex.get_image())
	
	self._last_texture = tex
	self.texture_button.texture_click_mask = bitmap

# Private ====================

func _get_tex_from_node () :
	var tex : Texture2D = null
	if self.from_node == null : return
	if "texture" in self.from_node :
		tex = self.from_node.texture
	if self.from_node is AnimatedSprite2D :
		tex = self.from_node.sprite_frames.get_frame_texture(self.from_node.animation, self.from_node.frame)
	return tex

