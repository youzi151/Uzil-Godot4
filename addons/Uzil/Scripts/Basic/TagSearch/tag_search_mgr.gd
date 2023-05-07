extends Node

## TagSearch.Mgr 標籤檢索 實體 管理
##
## 以key取得/建立 實體.
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

## 預設 設定
var _default_config = null

# GDScript ===================

func _init () :
	self._default_config = G.v.Uzil.Basic.TagSearch.Config.new()

func _process (_dt) :
	pass


# Public =====================

func inst (_key := "") :
	if self._key_to_inst.has(_key):
		return self._key_to_inst[_key]
	else:
		var _inst = G.v.Uzil.Basic.TagSearch.Inst.new(self._default_config)
		
		self._key_to_inst[_key] = _inst
		return _inst


# Private ====================

