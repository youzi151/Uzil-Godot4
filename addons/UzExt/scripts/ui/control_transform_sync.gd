@tool
extends Node

## Control Transform屬性同步
## 
## 使 來源Control的Transform屬性 同步至 目標Control
## 


# Variable ===================

## 是否啟用
@export
var is_enabled : bool = true :
	set (value) :
		is_enabled = value
		if is_enabled :
			self.sync()

## 來源目標
@export
var src_target : Control = null :
	set (value) :
		var last := src_target
		src_target = value
		self._reg_to_src(last, src_target)
		self.sync()

## 是否同步 尺寸
@export
var is_sync_size_x : bool = false :
	set (value) :
		is_sync_size_x = value
		self._sync_size()

@export
var is_sync_size_y : bool = false :
	set (value) :
		is_sync_size_y = value
		self._sync_size()

## 是否同步 縮放
@export
var is_sync_scale_x : bool = false :
	set (value) :
		is_sync_scale_x = value
		self._sync_size()
@export
var is_sync_scale_y : bool = false :
	set (value) :
		is_sync_scale_y = value
		self._sync_size()

## 同步目標
@export
var dst_targets : Array[Control] = [] :
	set (value) :
		dst_targets = value
		self.sync()

## 是否正在同步中
var _is_syncing := false

## 目標 最後一次的縮放
var _last_scale : Vector2 = Vector2.ZERO
## 是否持續追蹤縮放
var _is_track_scale : bool = false

# GDScript ===================

func _process (_dt: float) :
	if self._is_track_scale :
		if self._last_scale != self.src_target.scale :
			self._sync_size()
			

func _enter_tree() :
	self._connect(self.src_target)

func _exit_tree () :
	self._disconnect(self.src_target)

# Extends ====================

# Interface ==================

# Public =====================

func sync () :
	self._sync_size()

# Private ====================

## 同步尺寸
func _sync_size () :
	if not self.is_enabled : return
	if self._is_syncing : return
	if self.src_target == null : return
	
	self._is_syncing = true
	
	self._do_to_targets(self._sync_size_to)
	self._last_scale = self.src_target.scale
	
	self._is_syncing = false

## 同步尺寸至目標
func _sync_size_to (target : Control) :
	if target == null : return
	if target == self.src_target : return
	
	var size : Vector2 = target.size
	
	var is_any_size_change : bool = false
	
	if self.is_sync_size_x :
		var width_scale = self.src_target.size.x / target.size.x if target.size.x > 0.0 else 0.0
		
		size.x = self.src_target.size.x
		target.offset_left *= width_scale
		target.offset_right *= width_scale
		is_any_size_change = true
	if self.is_sync_size_y :
		var height_scale = self.src_target.size.y / target.size.y if target.size.y > 0.0 else 0.0
		size.y = self.src_target.size.y
		target.offset_top *= height_scale
		target.offset_bottom *= height_scale
		is_any_size_change = true
	
	if is_any_size_change :
		target.custom_minimum_size = size
		target.size = size
	
	if self._is_track_scale :
		var scale : Vector2 = target.scale
		
		if self.is_sync_scale_x :
			scale.x = self.src_target.scale.x
		if self.is_sync_scale_y :
			scale.y = self.src_target.scale.y
			
		target.scale = scale
	

## 對目標做...事
func _do_to_targets (fn: Callable) :
	for each in self.dst_targets :
		fn.call(each)

## 轉移註冊至目標
func _reg_to_src (last_src, new_src) :
	if last_src != null :
		self._disconnect(last_src)
	
	self._is_track_scale = false
	self._last_scale = Vector2.ZERO
	
	if new_src != null :
		
		self._connect(src_target)
		
		if "scale" in new_src :
			self._is_track_scale = true
			self._last_scale = new_src.scale

func _connect (target: Control) :
	if target == null : return
	if not target.resized.is_connected(self._on_resized) :
		target.resized.connect(self._on_resized)

func _disconnect (target: Control) :
	if target == null : return
	if target.resized.is_connected(self._on_resized) :
		target.resized.disconnect(self._on_resized)
		

func _on_resized () :
	self._sync_size()
