@tool
extends Node

## Control 比例縮放器
## 
## 以 Scale縮放 來 維持 目標Control 比例至 容器Control
## 

# 貼合模式
enum FitMode {
	WIDTH,
	HEIGHT,
	BOTH,
	COVER,
}

# Variable ===================

## 是否啟用
@export
var is_enabled : bool = true :
	set (value) :
		var is_diff := is_enabled != value
		is_enabled = value
		if is_diff and is_enabled :
			self._refresh()

## 貼合模式
@export
var fit_mode : FitMode = FitMode.BOTH :
	set (value) :
		fit_mode = value
		self._refresh()
		self.notify_property_list_changed()

## 是否 改變另一邊尺寸 [br]
## 當 Fit WIDTH/HEIGHT 將dst的主要邊以scale縮放貼齊src時, 改變dst另一邊的尺寸(非scale) 使其貼齊src.[br]
## 可以用在 希望dst是以scale縮放至src, 且又需要與比例與src一致/滿框時. 
@export
var is_resize_other_side : bool = false

## 來源
@export
var src_target : Control = null :
	set (value) :
		self._disconnect(src_target)
		src_target = value
		self._connect(value)
		self._refresh()

## 目標 縮放 [br]
## 通常會單獨用一個size(0,0)的control來單獨縮放scale.
@export
var dst_scaler : Control = null :
	set (value) :
		dst_scaler = value
		self._refresh()

## 目標 內容
@export
var dst_content : Control = null :
	set (value) :
		self._disconnect(dst_content)
		dst_content = value
		self._connect(value)
		self._refresh()

## 是否暫時忽略更新
var _is_ignore_refresh := false

# GDScript ===================

func _ready () :
	self._refresh()

func _validate_property (property: Dictionary) -> void :
	match property.name : 
		# 是否 改變另一邊尺寸
		"is_resize_other_side" :
			match self.fit_mode : 
				# 貼齊其中一邊時才顯示
				FitMode.WIDTH, FitMode.HEIGHT :
					property.usage |= PROPERTY_USAGE_EDITOR
				# 否則隱藏
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

## 刷新
func _refresh () :
	# 若 非啟用 或 忽略刷新 則 返回
	if not self.is_enabled or self._is_ignore_refresh : return
	# 若 無目標 則返回
	if self.dst_content == null : return
	
	# 來源 尺寸 與 實際尺寸(縮放過的)
	var src_size := Vector2.ONE
	var src_size_rect := Vector2.ONE
	# 取 來源
	if self.src_target != null :
		src_size = self.src_target.size
		src_size_rect = self.src_target.get_global_rect().size
	# 或 取root為來源
	else :
		if Engine.is_editor_hint() : return
		if not self.is_inside_tree() : return
		src_size = self.get_tree().root.size
		src_size_rect = src_size
	
	self._is_ignore_refresh = true
	
	var scale : float = 1.0
	var is_fit_width : bool = true
	var is_resize_other_side : bool = false
	
	# 依照 貼合模式
	match self.fit_mode :
		FitMode.WIDTH :
			is_fit_width = true
			is_resize_other_side = self.is_resize_other_side
		FitMode.HEIGHT :
			is_fit_width = false
			is_resize_other_side = self.is_resize_other_side
		_ :
			var src_target_ratio : float = src_size.x / src_size.y
			var dst_content_ratio : float = self.dst_content.size.x / self.dst_content.size.y
			if self.fit_mode == FitMode.COVER :
				is_fit_width = dst_content_ratio < src_target_ratio
			elif self.fit_mode == FitMode.BOTH :
				is_fit_width = dst_content_ratio > src_target_ratio
	# 貼合 寬 或 高
	if is_fit_width :
		scale = src_size_rect.x / self.dst_content.size.x
	else :
		scale = src_size_rect.y / self.dst_content.size.y
	
	# 若要自動調整另一邊尺寸
	if is_resize_other_side :
		var size : Vector2 = self.dst_content.size
		if is_fit_width :
			size.y = src_size.y / scale
		else :
			size.x = src_size.x / scale
		# 應用尺寸
		self._apply_size(self.dst_content, size)
	
	# 設置 目標 縮放
	var dst_scaler : Control = self.dst_scaler
	if dst_scaler == null : dst_scaler = self.dst_content
	dst_scaler.scale.x = scale
	dst_scaler.scale.y = scale
	
	self._is_ignore_refresh = false

## 應用尺寸
func _apply_size (target: Control, size_new: Vector2) :
	if is_nan(size_new.x) or is_nan(size_new.y) : return
	
	self._is_ignore_refresh = true
	var size_last : Vector2 = target.size
	var size_delta : Vector2 = size_new - size_last
	
	# 借用 grow direction, 依照方向改變需要的尺寸
	match target.grow_horizontal :
		Control.GROW_DIRECTION_BEGIN :
			target.offset_left -= size_delta.x
		Control.GROW_DIRECTION_END : 
			target.offset_right += size_delta.x
		Control.GROW_DIRECTION_BOTH : 
			var half : float = size_delta.x * 0.5
			target.offset_left -= half
			target.offset_right += half
	match target.grow_vertical :
		Control.GROW_DIRECTION_BEGIN :
			target.offset_top -= size_delta.y
		Control.GROW_DIRECTION_END : 
			target.offset_bottom += size_delta.y
		Control.GROW_DIRECTION_BOTH : 
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
