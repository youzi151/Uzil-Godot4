extends Node

## Invoker.Mgr 呼叫器 實體 管理
##
## 以key取得/建立 呼叫器 實體
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

# GDScript ===================

func _init (_dont_set_in_scene) :
	pass
	
func _process (_dt) :
	for key in self._key_to_inst:
		var _inst = self._key_to_inst[key]
		_inst.process(_dt)


# Public =====================

## 取得 實體
func inst (key := "_") :
	if self._key_to_inst.has(key) :
		return self._key_to_inst[key]
	else:
		var Invoker = UREQ.access_g("Uzil", "Core.Invoker")
		var _inst = Invoker.Inst.new().init(key)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

