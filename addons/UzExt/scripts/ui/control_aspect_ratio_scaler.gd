@tool
extends Node

## Control 比例縮放器
## 
## 以 Scale縮放 來 維持 目標Control 比例至 容器Control
## 

enum StretchMode {
	WIDTH_CONTROLS_HEIGHT,
	HEIGHT_CONTROLS_WIDTH,
	FIT,
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
var stretch_mode : StretchMode = StretchMode.FIT :
	set (value) :
		stretch_mode = value
		self._refresh()

@export
var src_target : Control = null :
	set (value) :
		self._disconnect(src_target)
		src_target = value
		self._connect(value)
		self._refresh()

@export
var dst_target : Control = null :
	set (value) :
		self._disconnect(dst_target)
		dst_target = value
		self._connect(value)
		self._refresh()

var _is_refreshing := false

# GDScript ===================

func _ready () :
	self._refresh()

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

func _refresh () :
	if not self.is_enabled or self._is_refreshing : return
	if self.dst_target == null : return
	
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
	
	self._is_refreshing = true
	
	var scale : float = 1.0
	var is_fit_width : bool = true
	
	if self.stretch_mode == StretchMode.WIDTH_CONTROLS_HEIGHT :
		is_fit_width = true
	elif self.stretch_mode == StretchMode.HEIGHT_CONTROLS_WIDTH :
		is_fit_width = false
	else :
		var src_target_ratio : float = src_size.x / src_size.y
		var dst_target_ratio : float = self.dst_target.size.x / self.dst_target.size.y
		if self.stretch_mode == StretchMode.COVER :
			is_fit_width = dst_target_ratio < src_target_ratio
		elif self.stretch_mode == StretchMode.FIT :
			is_fit_width = dst_target_ratio > src_target_ratio
	
	if is_fit_width :
		scale = src_size_scaled.x / self.dst_target.size.x
	else :
		scale = src_size_scaled.y / self.dst_target.size.y
	
	self.dst_target.scale.x = scale
	self.dst_target.scale.y = scale
	
	self._is_refreshing = false

func _connect (target : Control) :
	if target == null : return
	if not target.resized.is_connected(self._refresh) :
		target.resized.connect(self._refresh)

func _disconnect (target : Control) :
	if target == null : return
	if target.resized.is_connected(self._refresh) :
		target.resized.disconnect(self._refresh)
