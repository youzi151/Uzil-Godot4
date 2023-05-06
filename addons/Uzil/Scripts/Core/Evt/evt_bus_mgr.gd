extends Node

## Evt.BusMgr 事件串 管理
## 
## 以key取得/建立 事件串
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

## 預設 實體
var _default_inst = null

# GDScript ===================

func _init () :
	self._default_inst = self.inst("default")

func _process (_dt) :
	pass


# Public =====================

## 取得 實體
func inst (key := "") :
	if key == "" :
		return self._default_inst
		
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var _inst = G.v.Uzil.Core.Evt.Bus.new()
		_inst.name = key
		self.add_child(_inst)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

