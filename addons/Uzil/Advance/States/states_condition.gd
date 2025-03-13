extends Object

# Variable ===================

## 辨識
var id : String = ""

## 策略
var handlers : Array = []

## 資料
var data : Dictionary = {}

# GDScript ===================

# Extends ====================

# Public =====================

func set_dict (dict: Dictionary) :
	if dict.has("handlers") :
		self.handlers = dict["handlers"]
	if dict.has("data") :
		self.data = dict["data"]

# Private ====================
