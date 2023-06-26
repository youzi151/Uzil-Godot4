extends Node

# Variable ===================

const ROOT_PATH := "res://addons/UREQ"
const PATH = ROOT_PATH + "/Scripts"

const AccessType = {
	# 預設
	"DEFAULT" = 0,
	# 單例
	"SINGLETON" = 1,
	# 物件池
	"POOL" = 2,
}

var Access = null
var Scope = null

var key_to_scope := {}

# GDScript ===================

func _init () :
	# 移除先前的
	if G.v.has("UREQ") :
		if is_instance_valid(G.v.UREQ) :
			var g_node : Node = G.v.UREQ
			g_node.get_parent().remove_child(g_node)
			g_node.free()
	
	# 設置 為 全域G變數 UREQ
	G.set_global("UREQ", self)
	
	self.Access = self.load_script(PATH.path_join("ureq_access.gd"))
	self.Scope = self.load_script(PATH.path_join("ureq_scope.gd"))

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 存取 (全域) access
func gacc (id : String) :
	return self.scope().access(id)

## 存取 (指定範圍) access
func acc (key : String, id : String) :
	return self.scope(key).access(id)

## 綁定 (全域)
func gbind (id : String, inst, options := {}) :
	return self.scope().bind(id, inst, options)

## 綁定 (指定範圍)
func bind (key : String, id : String, inst, options := {}) :
	self.scope(key).bind(id, inst, options)

## 安裝
func install () :
	self.scope().install()

## 安裝 (指定範圍)
func install_g (key : String) :
	self.scope(key).install()

## 取得 範圍
func scope (key := "") :
	if self.key_to_scope.has(key) :
		return self.key_to_scope[key]
	
	var scope = self.Scope.new(self)
	self.key_to_scope[key] = scope
	return scope

## 讀取腳本
func load_script (path) :
	var stack = get_stack()
	for each in stack :
		if each.source == path :
			push_error("can't load script already in run stack")
			return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

# Private ====================
