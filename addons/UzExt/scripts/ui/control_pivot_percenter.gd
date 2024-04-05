@tool
extends Node

## Control中心點 維持百分比
## 
## 使 Control的中心點(影響旋轉與縮放) 以百分比設置
## 

# Variable ===================

## 是否啟用
@export
var is_enabled : bool = true :
	set (value) :
		is_enabled = value
		if is_enabled :
			self.refresh()

## 目標
@export
var target : Control = null : 
	set (value) :
		var last : Control = target
		target = value
		
		if target != null :
			if not target.resized.is_connected(self.refresh) :
				target.resized.connect(self.refresh)
		if last != null :
			if last.resized.is_connected(self.refresh) :
				last.resized.disconnect(self.refresh)
		
		self.refresh()

## 中心點百分比
@export
var pivot_percent : Vector2 = Vector2(0.0, 0.0) :
	set (value) :
		pivot_percent = value
		self.refresh()

## 是否正在更新中
var _is_refreshing : bool = false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

## 刷新
func refresh () :
	if not self.is_enabled : return
	
	if self.target == null : return
	
	# 若 已在更新中 則 返回
	if self._is_refreshing : return
	self._is_refreshing = true
	
	# 重設 中心點偏移 為 尺寸*百分比
	self.target.pivot_offset.x = self.target.size.x * self.pivot_percent.x
	self.target.pivot_offset.y = self.target.size.y * self.pivot_percent.y

	self._is_refreshing = false
