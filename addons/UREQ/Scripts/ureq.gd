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
var Group = null

var key_to_group := {}

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
	self.Group = self.load_script(PATH.path_join("ureq_group.gd"))

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 存取
func access (id : String) :
	return self.group().access(id)

## 存取 (指定群組)
func access_g (key : String, id : String) :
	return self.group(key).access(id)

## 綁定
func bind (id : String, inst, options := {}) :
	return self.group().bind(id, inst, options)

## 綁定 (指定群組)
func bind_g (key : String, id : String, inst, options := {}) :
	self.group(key).bind(id, inst, options)

## 安裝
func install () :
	self.group().install()

## 安裝 (指定群組)
func install_g (key : String) :
	self.group(key).install()

## 取得 群組
func group (key := "") :
	if self.key_to_group.has(key) :
		return self.key_to_group[key]
	
	var group = self.Group.new(self)
	self.key_to_group[key] = group
	return group

## 讀取腳本
func load_script (path) :
	var stack = get_stack()
	for each in stack :
		if each.source == path :
			push_error("can't load script already in run stack")
			return null
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

# Private ====================
