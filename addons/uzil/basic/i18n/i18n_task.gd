
## i18n task 翻譯任務
##
## 每一個 原始字串 轉換為 翻譯字串 的 任務資料.
##

# Variable ===================

## 在地化 實體
var inst = null

## 內文
var text : String = ""

## 格式化資料
var format : Variant = null

# GDScript ===================

func _init (_inst, _text, _format) :
	self.inst = _inst
	self.text = _text
	self.format = _format

# Extends ====================

# Public =====================

# Private ====================
