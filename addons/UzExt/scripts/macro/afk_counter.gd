extends Node

# Variable ===================

## 當 閒置
signal on_afk

## 是否啟用
@export
var is_enabled : bool = true

## 最大閒置時間
@export
var max_afk_time_sec : float = -1.0

## 已閒置時間
var afk_time_sec : float = -1.0

# GDScript ===================

func _process (_dt: float) :
	if not self.is_enabled : return
	
	if Input.is_anything_pressed() :
		self.keep()
	
	if self.max_afk_time_sec < 0.0 : return
	if self.afk_time_sec < 0.0 : return
	
	self.afk_time_sec += _dt
	if self.afk_time_sec > self.max_afk_time_sec :
		self._afk_emit()
		self.afk_time_sec = -1.0

func _input (event: InputEvent) -> void :
	self.keep()


# Extends ====================

# Interface ==================

# Public =====================

func keep () :
	self.afk_time_sec = 0.0

func start () :
	self.is_enabled = true
	self.afk_time_sec = 0.0

func stop () :
	self.is_enabled = false
	self.afk_time_sec = 0.0

func pause () :
	self.is_enabled = false

func resume () :
	self.is_enabled = true

# Private ====================

func _afk_emit () :
	self.on_afk.emit()
