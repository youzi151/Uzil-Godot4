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
	self.Log = ResourceLoader.load("res://addons/GlobalUtil/Scripts/logger.gd").new()

func _enter_tree () :
	self.set_global("main_window", self.get_window())

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


## 報錯
func error (msg) :
	self.Log.do_error(msg)

## 註冊 當印出
func on_print (fn : Callable, tag : String = "") :
	return self.Log.on_print(fn, tag)

## 註銷 當印出
func off_print (tag : String = "") :
	self.Log.off_print(tag)

## 讀取腳本
func load_script (path : String) :
	var stack = get_stack()
	for each in stack :
		if each.source == path :
			push_error("can't load script already in run stack")
			return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

# Private ====================

