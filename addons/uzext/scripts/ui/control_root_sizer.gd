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


## 同步目標
@export
var dst_target : Control = null :
	set (value) :
		dst_target = value
		self.sync()

@export
var size_in_dev : Vector2i = Vector2i(1920, 1080) :
	set (value) :
		size_in_dev = value
		self.sync()

## 是否正在同步中
var _is_syncing := false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	self.sync.call_deferred()

# Extends ====================

# Interface ==================

# Public =====================

func sync () :
	self._sync_size()

# Private ====================

## 同步尺寸
func _sync_size () :
	if self._is_syncing : return
	
	self._is_syncing = true
	
	if Engine.is_editor_hint() :
		self.dst_target.size = self.size_in_dev
		self.dst_target.set_anchors_preset(Control.PRESET_TOP_LEFT)
	else :
		if self.is_inside_tree() :
			var root := self.get_tree().root
			self.dst_target.size = root.size
			self.dst_target.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	self._is_syncing = false


## 轉移註冊至目標
func _reg_to_src (last_src, new_src) :
	if last_src != null :
		self._disconnect(last_src)
		
	if new_src != null :
		self._connect(new_src)

func _connect (target: Control) :
	if target == null : return
	if not target.resized.is_connected(self._sync_size) :
		target.resized.connect(self._sync_size)

func _disconnect (target: Control) :
	if target == null : return
	if target.resized.is_connected(self._sync_size) :
		target.resized.disconnect(self._sync_size)
