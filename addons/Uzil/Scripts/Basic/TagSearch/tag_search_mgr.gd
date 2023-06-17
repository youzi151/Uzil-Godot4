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

func _init (_dont_set_in_scene) :
	var TagSearch = UREQ.access_g("Uzil", "TagSearch")
	self._default_config = TagSearch.Config.new()

func _process (_dt) :
	pass


# Public =====================

func inst (key := "_") :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var TagSearch = UREQ.access_g("Uzil", "Basic.TagSearch")
		var _inst = TagSearch.Inst.new(self._default_config)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

