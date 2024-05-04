extends Node

## Evt.BusMgr 事件串 實體 管理
## 
## 以key取得/建立 事件串.
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

# GDScript ===================

func _init (_dont_set_in_scene) :
	pass

# Public =====================

## 取得 實體
func inst (key := "_") :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var Evt = UREQ.acc("Uzil", "Core.Evt")
		var _inst = Evt.Bus.new()
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

