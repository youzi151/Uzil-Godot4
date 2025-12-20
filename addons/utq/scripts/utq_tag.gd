## UTQ Tag
## 
## UTQ 標籤查詢系統標籤資料類別
##

# Variable ===================

## 所屬
var scope: String = ""

## 值
var val: String = ""

## 屬性字串
var attr: String = ""

## 搜尋類型
var search_type: int = 0  # 使用 SearchType enum

## wild例外列表
var wild_excepts: Array = []

## 字串快取
var _string_cache: String = ""

# GDScript ===================

func _init (dict := {}) :
	self.scope = dict.get("scope", "")
	self.val = dict.get("val", "")
	self.attr = dict.get("attr", "")
	self.search_type = dict.get("search_type", 0)

func _to_string () -> String :
	if self._string_cache.is_empty():
		self._string_cache = self._build_string()
	return self._string_cache

# Public =====================

# Private =====================

func _build_string () -> String :
	var str := "<"
	
	if self.val.is_empty():
		return "<invalid tag>"
	
	# 添加搜尋類型符號
	match self.search_type:
		-2:
			str += "--"
		-1:
			str += "-"
		0:
			str += "*"
		1:
			str += "+"
		2:
			str += ""
	
	# 添加屬性字串
	if not self.attr.is_empty():
		str += self.attr
	
	# 添加範圍
	if not self.scope.is_empty():
		str += self.scope + ":"
	
	# 添加值
	str += self.val
	
	if self.wild_excepts.size() > 0 :
		str = "%s^%s" % [str, "^".join(self.wild_excepts)]
	
	str += ">"
	
	return str
