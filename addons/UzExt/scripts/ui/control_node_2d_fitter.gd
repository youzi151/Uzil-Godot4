@tool
extends Node

## Control與Node2D適配器
## 
## 使 Node2D縮放 至 Control的尺寸
## 或使 Control調整尺寸 至 依照Node2D的尺寸(貼圖或其他)
## 

enum FitMode {
	CONTROL, NODE2D
}

# Variable ===================

## 是否啟用
@export
var is_enabled : bool = true :
	set (value) :
		is_enabled = value
		if is_enabled :
			self.sync()
			

## 適用目標類型
@export
var fit_to : FitMode = FitMode.CONTROL :
	set (value) :
		fit_to = value
		self.sync()

## 目標Control
@export
var control : Control = null :
	set (value) :
		var last_control : Control = control
		control = value
		
		if last_control != null :
			self._disconnect_control(last_control)
		
		if control != null :
			self._connect_control(control)
		
		self.sync()

## 目標Node2D
@export
var node2d : Node2D = null :
	set (value) :
		var last_node2d : Node2D = node2d
		node2d = value
		
		if last_node2d != null :
			self._disconnect_node2d(last_node2d)
		
		self._last_scale = Vector2.ZERO
		if node2d != null :
			self._connect_node2d(node2d)
			if "scale" in node2d :
				self._last_scale = node2d.scale
		
		self.sync()

## 是否正在同步中
var _is_syncing := false

## 目標 control或node2D 最後一次的scale縮放
var _last_scale : Vector2 = Vector2.ZERO

# GDScript ===================

func _init () :
	pass

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	if not is_enabled : return
	
	# 檢查目標的scale有無變化
	var target = null
	match self.fit_to :
		FitMode.NODE2D :
			target = self.node2d
		FitMode.CONTROL :
			target = self.control
			
	# 若有變化 則 執行同步
	if target != null :
		if self._last_scale != target.scale :
			self._last_scale = target.scale
			self.sync()


# Extends ====================

# Interface ==================

# Public =====================


func sync () :
	if not self.is_enabled : return
	if self.control == null or self.node2d == null : return
	
	# 若 已經在同步中 則 返回
	if self._is_syncing : return
	self._is_syncing = true
	
	# node2d的尺寸 (用於重設位置)
	var node2d_size : Vector2
	
	# 依照 適配模式
	match self.fit_to :
		FitMode.NODE2D :
			# 先取得為原始尺寸
			node2d_size = self._get_node2d_raw_size(self.node2d)
			# 乘上縮放成為實際尺寸
			node2d_size *= self.node2d.scale
			# 以 node2d實際尺寸 設置 control尺寸
			self.control.custom_minimum_size = node2d_size
			self.control.set_size(node2d_size, false)
		
		FitMode.CONTROL :
			# 設置 node2d尺寸 為 control的尺寸 並得到 node2d原始尺寸
			node2d_size = self._set_node2d_scale_to_size(self.node2d, self.control.size)
			# 乘上縮放成為實際尺寸
			node2d_size *= self.node2d.scale
	
	# 重設 node2d 位置
	self._reset_node2d_position(self.node2d, node2d_size)
	
	self._is_syncing = false



# Private ====================

## 取得 node2d原始尺寸
func _get_node2d_raw_size (target : Node2D) :
	
	var size := Vector2.ZERO
	if "texture" in target :
		if target.texture != null : 
			size = target.texture.get_size()
	
	elif target is AnimatedSprite2D :
		if target.sprite_frames != null :
			var atlas_tex : AtlasTexture = target.sprite_frames.get_frame_texture(target.animation, target.frame)
			size = atlas_tex.get_size()
	
	return size

## 設置 node2d縮放至尺寸 (順便回傳node2d原始尺寸)
func _set_node2d_scale_to_size (target : Node2D, size : Vector2) :
	if target == null : return
	var tex_size : Vector2 = self._get_node2d_raw_size(target)
	
	# 要 縮放多少 才能適配至 目標尺寸
	var scale : Vector2 = target.scale
	scale.x = size.x / tex_size.x
	scale.y = size.y / tex_size.y
	
	# 改變 縮放
	target.scale = scale
	
	return tex_size

## 重設 node2d 位置
func _reset_node2d_position (target, node2d_size : Vector2) :
	
	if target is Sprite2D :
		if target.centered :
			var pos : Vector2 = (node2d_size * 0.5) - target.offset
			target.position = pos
		else :
			target.position = Vector2.ZERO
	
	elif target is AnimatedSprite2D :
		if target.centered :
			var pos : Vector2 = (node2d_size * 0.5) - target.offset
			target.position = pos
		else :
			target.position = Vector2.ZERO
	
	elif "offset" in target :
		var pos : Vector2 = (node2d_size * 0.5) - target.offset
		target.position = pos
	

func _connect_control (target : Control) :
	if target == null : return
	if not target.resized.is_connected(self.sync) :
		target.resized.connect(self.sync)

func _disconnect_control (target : Control) :
	if target == null : return
	if target.resized.is_connected(self.sync) :
		target.resized.disconnect(self.sync)

func _connect_node2d (target : Node2D) :
	if target == null : return
	if not target.item_rect_changed.is_connected(self.sync) :
		target.item_rect_changed.connect(self.sync)

func _disconnect_node2d (target : Node2D) :
	if target == null : return
	if target.item_rect_changed.is_connected(self.sync) :
		target.item_rect_changed.disconnect(self.sync)
