extends Node

## Times.Mgr 時間 實體 管理
##
## 以key取得/建立 時間軸 實體
##

# Variable ===================

## key:實體 表
var key_to_inst := {}

## 預設 實體
var _default_inst = null

# GDScript ===================

func _init () :
	self._default_inst = self.inst("default")

func _process (_dt) :
	for key in self.key_to_inst:
		var _inst = self.key_to_inst[key]
		_inst.process(_dt)


# Public =====================

## 取得 實體
func inst (key := "") :
	if key == "" :
		return self._default_inst
		
	if self.key_to_inst.has(key) :
		return self.key_to_inst[key]
	else:
		var _inst = G.v.Uzil.Core.Times.Inst.new()
		_inst.name = key
		self.add_child(_inst)
		
		self.key_to_inst[key] = _inst
		return _inst

# Private ====================
