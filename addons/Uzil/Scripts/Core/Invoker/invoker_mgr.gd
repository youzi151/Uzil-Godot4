extends Node

## Invoker.Mgr 呼叫器 實體 管理
##
## 以key取得/建立 呼叫器 實體
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

# GDScript ===================

func _init () :
	pass
	
func _process (_dt) :
	for key in self._key_to_inst:
		var _inst = self._key_to_inst[key]
		_inst.process(_dt)


# Public =====================

## 取得 實體
func inst (key := "") :
	if self._key_to_inst.has(key) :
		return self._key_to_inst[key]
	else:
		var _inst = G.v.Uzil.Core.Invoker.Inst.new().init(key)
		_inst.name = key
		self.add_child(_inst)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

