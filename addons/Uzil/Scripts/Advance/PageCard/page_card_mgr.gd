extends Node

## PageCard.Mgr 頁面卡 實體 管理
## 
## 以key取得/建立 實體.
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

## 取得 頁面卡 實體
func inst (key := "_", _root_page = null) :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var PageCard = UREQ.access_g("Uzil", "Advance.PageCard")
		var _inst = PageCard.Inst.new(_root_page)
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

