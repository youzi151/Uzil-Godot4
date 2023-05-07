extends Node

## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = "" :
	get :
		if _id == "" : return self.name
		else : return self._id
	set (value) :
		self._id = value
var _id : String = ""

## 卡片
@export var cards : Array[String] = []

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass

# Public =====================

# Private ====================
