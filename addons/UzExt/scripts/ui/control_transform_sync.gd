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
var is_sync_size : bool = false :
	set (value) :
		is_sync_size = value
		self._sync_size()

## 是否同步 縮放
@export
var is_sync_scale : bool = false :
	set (value) :
		is_sync_scale = value
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
			

# Extends ====================

# Interface ==================

# Public =====================

func sync () :
	self._sync_size()

# Private ====================

## 同步尺寸
func _sync_size () :
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
	
	if self.is_sync_size :
		var width_scale = self.src_target.size.x / target.size.x
		var height_scale = self.src_target.size.y / target.size.y
		target.custom_minimum_size = self.src_target.size
		target.offset_left *= width_scale
		target.offset_right *= width_scale
		target.offset_top *= height_scale
		target.offset_bottom *= height_scale
	
	if self.is_sync_scale and self._is_track_scale :
		target.scale = self.src_target.scale
	

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
	if not target.resized.is_connected(self._sync_size) :
		target.resized.connect(self._sync_size)

func _disconnect (target: Control) :
	if target == null : return
	if target.resized.is_connected(self._sync_size) :
		target.resized.disconnect(self._sync_size)
		

