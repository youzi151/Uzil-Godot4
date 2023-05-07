extends Node

## StateMachine.Mgr 狀態機 實體 管理
##
## 以key取得/建立 實體.
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass


# Public =====================

func inst (_key := "") :
	if self._key_to_inst.has(_key):
		return self._key_to_inst[_key]
	else:
		var _inst = G.v.Uzil.Advance.StateMachine.Inst.new()
		
		self._key_to_inst[_key] = _inst
		return _inst


# Private ====================

