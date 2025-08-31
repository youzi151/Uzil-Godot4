extends RefCounted

# Variable ===================

## 辨識
var id : String = ""

## 策略
var handlers : Array = []

## 轉場
var transitions : Array = []

## 資料
var data : Dictionary = {}

# GDScript ===================

# Extends ====================

# Public =====================

func set_dict (dict: Dictionary) :
	if dict.has("handlers") :
		self.handlers = dict["handlers"]
	if dict.has("transitions") :
		self.transitions = dict["transitions"]
	if dict.has("data") :
		self.data = dict["data"]

# Private ====================
