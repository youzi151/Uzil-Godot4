extends Node

## Times.Mgr 時間 實體 管理
##
## 以key取得/建立 時間軸 實體.
##

# Variable ===================

## key:實體 表
var key_to_inst := {}

# GDScript ===================

func _init (_dont_set_in_scene) :
	pass

func _process (_dt) :
	for key in self.key_to_inst:
		var _inst = self.key_to_inst[key]
		_inst.process(_dt)


# Public =====================

## 取得 實體
func inst (key := "_") :
	if self.key_to_inst.has(key) :
		return self.key_to_inst[key]
	else:
		var Times = UREQ.access_g("Uzil", "Core.Times")
		var _inst = Times.Inst.new(null)
		_inst.name = key
		self.add_child(_inst)
		
		self.key_to_inst[key] = _inst
		return _inst

# Private ====================
