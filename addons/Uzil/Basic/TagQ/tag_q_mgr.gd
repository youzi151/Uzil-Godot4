extends Node

## TagQ.Mgr 標籤檢索 實體 管理
##
## 以key取得/建立 實體.
## 

# Variable ===================

## key:實體 表
var _key_to_inst := {}

## 預設 設定
var default_config = null

# GDScript ===================

func _init (_dont_set_in_scene) :
	var TagQ = UREQ.acc("Uzil", "TagQ")

# Public =====================

func inst (key := "_") :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var TagQ = UREQ.acc("Uzil", "Basic.TagQ")
		var _inst = TagQ.Inst.new(self.default_config)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

