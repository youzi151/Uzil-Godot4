extends Node

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = ""

## 面板設置 策略
@export var strat := ""

## 資料
@export var data := {}

## 實體
var state = null

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	self.request_state()

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Public =====================

func request_state () :
	if self.state != null : return self.state
	
	self.state = UREQ.acc("Uzil", "Advance.States").State.new(self.strat)
	
	if self.id == "" :
		self.state.id = self.name
	else :
		self.state.id = self.id
	
	self.state.set_data(self.data)
	
	return self.state

# Private ====================

