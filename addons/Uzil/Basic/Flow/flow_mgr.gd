extends Node

## Flow.Mgr 流程控制 實體 管理
##
## 以key取得/建立 流程控制 實體. [br]
## 並提供 相關腳本 的 註冊與取用.
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

# GDScript ===================

func _init (_dont_set_in_scene) :
	pass

func _process (_dt) :
	pass


# Public =====================

func inst (key := "_") :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var Flow = UREQ.acc("Uzil", "Basic.Flow")
		var _inst = Flow.Inst.new(null).init(key)
		_inst.name = key
		self.add_child(_inst)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

