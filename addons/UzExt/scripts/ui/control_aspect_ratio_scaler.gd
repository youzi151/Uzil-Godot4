@tool
extends Node

## Control 比例縮放器
## 
## 以 Scale縮放 來 維持 目標Control 比例至 容器Control
## 

enum StretchMode {
	FIT_WIDTH,
	FIT_HEIGHT,
	FIT_BOTH,
	COVER,
}

# Variable ===================

@export
var is_enabled : bool = true :
	set (value) :
		var is_diff := is_enabled != value
		is_enabled = value
		if is_diff and is_enabled :
			self._refresh()

@export
var stretch_mode : StretchMode = StretchMode.FIT_BOTH :
	set (value) :
		stretch_mode = value
		self._refresh()
		self.notify_property_list_changed()

@export
var is_resize_other_side : bool = false

@export
var src_target : Control = null :
	set (value) :
		self._disconnect(src_target)
		src_target = value
		self._connect(value)
		self._refresh()

@export
var dst_scaler : Control = null :
	set (value) :
		dst_scaler = value
		self._refresh()

@export
var dst_content : Control = null :
	set (value) :
		self._disconnect(dst_content)
		dst_content = value
		self._connect(value)
		self._refresh()


var _is_ignore_refresh := false

# GDScript ===================

func _ready () :
	self._refresh()

func _validate_property (property: Dictionary) -> void :
	match property.name : 
		"is_resize_other_side" :
			match self.stretch_mode : 
				StretchMode.FIT_WIDTH, StretchMode.FIT_HEIGHT :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

func _refresh () :
	if not self.is_enabled or self._is_ignore_refresh : return
	if self.dst_content == null : return
	
	var src_size := Vector2.ONE
	var src_size_scaled := Vector2.ONE
	if self.src_target != null :
		src_size = self.src_target.size 
		src_size_scaled = Vector2(src_size.x * src_target.scale.x, src_size.y * src_target.scale.y)
	else :
		if Engine.is_editor_hint() : return
		if not self.is_inside_tree() : return
		src_size = self.get_tree().root.size
		src_size_scaled = src_size
	
	self._is_ignore_refresh = true
	
	var scale : float = 1.0
	var is_fit_width : bool = true
	var is_resize_other_side : bool = false
	
	match self.stretch_mode :
		StretchMode.FIT_WIDTH :
			is_fit_width = true
			is_resize_other_side = self.is_resize_other_side
		StretchMode.FIT_HEIGHT :
			is_fit_width = false
			is_resize_other_side = self.is_resize_other_side
		_ :
			var src_target_ratio : float = src_size.x / src_size.y
			var dst_content_ratio : float = self.dst_content.size.x / self.dst_content.size.y
			if self.stretch_mode == StretchMode.COVER :
				is_fit_width = dst_content_ratio < src_target_ratio
			elif self.stretch_mode == StretchMode.FIT_BOTH :
				is_fit_width = dst_content_ratio > src_target_ratio
	
	if is_fit_width :
		scale = src_size_scaled.x / self.dst_content.size.x
	else :
		scale = src_size_scaled.y / self.dst_content.size.y
		
	if is_resize_other_side :
		var size : Vector2 = self.dst_content.size
		if is_fit_width :
			size.y = src_size.y / scale
		else :
			size.x = src_size.x / scale
			
		self.apply_size(self.dst_content, size)
		
	
	var dst_scaler : Control = self.dst_scaler
	if dst_scaler == null : dst_scaler = self.dst_content
	dst_scaler.scale.x = scale
	dst_scaler.scale.y = scale
	
	self._is_ignore_refresh = false

func apply_size (target: Control, size_new: Vector2) :
	if is_nan(size_new.x) or is_nan(size_new.y) : return
	
	self._is_ignore_refresh = true
	var size_last : Vector2 = target.size
	var size_delta : Vector2 = size_new - size_last
	match target.grow_horizontal :
		0 :
			target.offset_left -= size_delta.x
		1 : 
			target.offset_right += size_delta.x
		2 : 
			var half : float = size_delta.x * 0.5
			target.offset_left -= half
			target.offset_right += half
	match target.grow_vertical :
		0 :
			target.offset_top -= size_delta.y
		1 : 
			target.offset_bottom += size_delta.y
		2 : 
			var half : float = size_delta.y * 0.5
			target.offset_top -= half
			target.offset_bottom += half
	
	self._is_ignore_refresh = false

func _connect (target : Control) :
	if target == null : return
	if not target.resized.is_connected(self._refresh) :
		target.resized.connect(self._refresh)

func _disconnect (target : Control) :
	if target == null : return
	if target.resized.is_connected(self._refresh) :
		target.resized.disconnect(self._refresh)
