
## i18n translator 翻譯器
##
## 作為 翻譯實體 與 處理器 的 介面
##

# Variable ===================

## 翻譯 處理器
var _handler = null

# GDScript ===================

func _init (handler) :
	self._handler = handler

# Extends ====================

# Public =====================

## 翻譯
func handle (trans_task) :
	var is_trans = await self._handler.handle(trans_task)
	if is_trans == true : return true
	return false

# 字典 ===============

# Private ====================

