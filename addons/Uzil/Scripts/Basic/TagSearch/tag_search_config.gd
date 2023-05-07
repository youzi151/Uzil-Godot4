
## TagSearch.Config 設定
## 
## 一些 常數 或 正則式 的設定.
##

# Variable ===================


## 屬性 衝突
var ATTR_CONFLICT := "!"
## 屬性 需要
var ATTR_REQUIRE := "@"
## 屬性 隱藏
var ATTR_HIDE := "#"

## 暫時替換用的字元
var temp_replace_space_char := "\ufffe"

## 搜尋字串 分群 正則式
var search_str_group_regex_pattern := "\\(([^\\(\\)]*)\\)"
## 搜尋字串 分群 正則
var search_str_group_regex : RegEx = null

## 標籤字串 分群 正則式
var tag_str_group_regex_pattern := "[^,]+"
## 標籤字串 分群 正則
var tag_str_group_regex : RegEx = null

## 去頭尾空白 正則式
var no_begin_end_space_regex_pattern := "(?!\\ )(.+)(?<!\\ )"
## 去頭尾空白 正則
var no_begin_end_space_regex : RegEx = null

## 去符號前後空白 ":" 正則式
var no_space_around_scope_symbol_regex_pattern := "\\ +[:]\\ +"
## 去符號前後空白 ":" 正則
var no_space_around_scope_symbol_regex : RegEx = null

## 去符號前後空白 "," 正則式
var no_space_around_group_symbol_regex_pattern := "\\ +[,]\\ +"
## 去符號前後空白 "," 正則
var no_space_around_group_symbol_regex : RegEx = null

## 去符號後空白 "-" 正則式
var no_space_behind_negative_symbol_regex_pattern := "[-]\\ +"
## 去符號後空白 "-" 正則
var no_space_behind_negative_symbol_regex : RegEx = null

## 雙引號內 正則式
var any_in_quotes_regex_pattern := "\\\"([^\\\"]*)\\\""
## 雙引號內 正則
var any_in_quotes_regex : RegEx = null


# GDScript ===================

func _init () :
	self.search_str_group_regex = RegEx.new()
	self.search_str_group_regex.compile(self.search_str_group_regex_pattern)
	
	self.tag_str_group_regex = RegEx.new()
	self.tag_str_group_regex.compile(self.tag_str_group_regex_pattern)
	
	self.no_begin_end_space_regex = RegEx.new()
	self.no_begin_end_space_regex.compile(self.no_begin_end_space_regex_pattern)
	
	self.no_space_around_scope_symbol_regex = RegEx.new()
	self.no_space_around_scope_symbol_regex.compile(self.no_space_around_scope_symbol_regex_pattern)
	
	self.no_space_around_group_symbol_regex = RegEx.new()
	self.no_space_around_group_symbol_regex.compile(self.no_space_around_group_symbol_regex_pattern)
	
	self.no_space_behind_negative_symbol_regex = RegEx.new()
	self.no_space_behind_negative_symbol_regex.compile(self.no_space_behind_negative_symbol_regex_pattern)
	
	self.any_in_quotes_regex = RegEx.new()
	self.any_in_quotes_regex.compile(self.any_in_quotes_regex_pattern)
	

# Public =====================
