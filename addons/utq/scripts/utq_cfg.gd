## UTQ Config
## 
## UTQ 標籤查詢系統配置類別
##

# Variable ===================

## 搜尋類型枚舉
enum SearchType {
	EXCLUDE = -2,        # 強制排除 (^號)
	WITHOUT = -1,        # 排除 (-號)
	TOLERANT = 0,        # 寬容 (*號)
	ANYONE = 1,          # 任一 (+號，支援範圍搜尋)
	REQUIRED = 2         # 必須 (無標記號)
}

## 同一個所屬中的標籤分隔符
var separator_tag_same_scope : String = ","
## 標籤分隔符
var seperator_tag : String = " "
## 所屬分隔符
var seperator_scope: String = ":"
## 所屬分隔符
var seperator_attr: String = "/"

## 運算子
var operator_intersection: String = "&"
var operator_symmetric_difference: String = "%"
var operator_union: String = "|"
var operator_fallback: String = ">"

## 運算子列表
var operators := [
	operator_intersection,
	operator_symmetric_difference,
	operator_union,
	operator_fallback,
]

## 搜尋類型符號
var prefix_without: String = "-"
var prefix_anyone: String = "+"
var prefix_tolerant: String = "*"

## 屬性識別符
var attr_conflict: String = "!"
var attr_required: String = "@"
var attr_hidden: String = "#"

## 特殊符號
var wildcard: String = "."
var wildcard_except: String = "^"
var wildcard_and_except: String = wildcard + wildcard_except

## 預設群組
var default_group: String = "default"

## 字符處理
var temp_space_char: String = "\ufffe"

## 正則表達式模式
var tag_string_group_pattern: String = "[^\\,\\\"]+"
var any_in_quotes_regex_pattern : String = "\\\"([^\\\"]*)\\\""
var redundant_space_regex_pattern : String = "([\\+\\-\\^\\*\\:\\,])\\ *"
var bracket_regex_pattern: String = "\\[(.*?)\\]"

## 編譯後的正則表達式物件
var tag_string_group_regex: RegEx
var any_in_quotes_regex : RegEx
var redundant_space_regex : RegEx
var bracket_regex: RegEx

# GDScript ===================

func _init () :
	self._compile_regex()

# Public =====================

func _compile_regex () :
	
	self.tag_string_group_regex = RegEx.new()
	self.tag_string_group_regex.compile(self.tag_string_group_pattern)
	
	self.any_in_quotes_regex = RegEx.new()
	self.any_in_quotes_regex.compile(self.any_in_quotes_regex_pattern)
	
	self.redundant_space_regex = RegEx.new()
	self.redundant_space_regex.compile(self.redundant_space_regex_pattern)
	
	self.bracket_regex = RegEx.new()
	self.bracket_regex.compile(self.bracket_regex_pattern)
