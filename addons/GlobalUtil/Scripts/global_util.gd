extends Node

## GlobalUtil
# 將此Node節點設為AutoLoad, 並命名為"G".
# 就可以用G.v.key或G.v["key"]的方式存取一個全域Dictionary中的值.

# add this node in to singleton/autoload, and name "G".
# then there is a global dictionary can access value with G.v.key or G.v["key"].

# Variable ===================

# 模塊 ======

## 傾印
var Log = null

# 成員 ======

## 變數
var v := {}

# GDScript ===================

func _init () :
	self.Log = preload("res://addons/GlobalUtil/Scripts/logger.gd").new()

# Extends ====================

# Interface ==================

# Public =====================

## 設置 全域變數
func set_global (_name : String, val) :
	self.v[_name] = val
	if _name in self :
		self[_name] = val

## 印出
func print (msg) :
	self.Log.do_print(msg)

## 註冊 當印出
func on_print (fn : Callable, tag : String = "") :
	return self.Log.on_print(fn, tag)

## 註銷 當印出
func off_print (tag : String = "") :
	self.Log.off_print(tag)

# Private ====================

