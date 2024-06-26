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

# Public =====================

## 取得 頁面卡 實體
func inst (key := "") :
	if self._key_to_inst.has(key):
		return self._key_to_inst[key]
	else:
		var PageCard = UREQ.acc(&"Uzil:Advance.PageCard")
		var _inst = PageCard.Inst.new()
		
		self._key_to_inst[key] = _inst
		return _inst


# Private ====================

