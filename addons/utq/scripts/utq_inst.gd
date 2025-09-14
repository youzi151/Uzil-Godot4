## UTQ Instance (Refactored)
## 
## UTQ 標籤查詢系統主控制器
## 負責協調各模組工作，提供對外介面
##

# Variable ===================

var UTQ

var target_to_data: Dictionary = {}  # target_data: tag_target_to_data

## 設定
var cfg

## 執行器 (執行搜尋字串與運算)
var executor

## 查詢器 (執行查詢資料)
var queryer

var is_debug := false

# GDScript ===================

## 初始化
func _init (_UTQ) :
	self.UTQ = _UTQ
	
	# 初始化各模組
	self.cfg = self.UTQ.Cfg.new()
	self.executor = self.UTQ.Executor.new(self)
	self.queryer = self.UTQ.Queryer.new(self)

# Public =====================

## 清空資料
func clear_data () :
	self.target_to_data.clear()

## 設定目標資料
func set_data (target, tags_str_or_tag) :
	var target_tags : Array = []
	if self.target_to_data.has(target) :
		target_tags = self.target_to_data[target]
		target_tags.clear()
	else :
		self.target_to_data[target] = target_tags
	
	var _tags : Array = tags_str_or_tag if typeof(tags_str_or_tag) == TYPE_ARRAY else [tags_str_or_tag]
	for tag in _tags:
		match typeof(tag) :
			TYPE_OBJECT :
				if tag.get_script() == self.UTQ.Tag :
					target_tags.push_back(tag)
			TYPE_STRING :
				var query_request : Dictionary = self.queryer.parse_query_str(tag)
				var type_to_group_to_tags : Dictionary = query_request["type_to_group_to_tags"]
				var unsigned_tags : Array = type_to_group_to_tags[self.cfg.SearchType.REQUIRED][0]
				target_tags.append_array(unsigned_tags)

## 取得目標資料
func get_data (target) :
	return self.target_to_data.get(target, null)

## 主要搜尋介面
func search (search_str: String) -> Dictionary :
	return self.executor.search(search_str)

## 直接查詢 (不經過語法解析)
func query (query_str: String) -> Dictionary :
	return self.queryer.query(query_str)

## 簡易解析標籤列表(不帶type, group)
func parse_tags (search_str: String) -> Array :
	var total_tags : Array = []
	var search_request : Array = self.executor.parse_search_str(search_str)
	for each in search_request :
		if each[0] != "s" : continue
		var query_str : String = each[1]
		var query_request : Dictionary = self.queryer.parse_query_str(query_str)
		var type_to_group_to_tags : Dictionary = query_request["type_to_group_to_tags"]
		for groups in type_to_group_to_tags.values() :
			for tags in groups :
				total_tags.append_array(tags)
	return total_tags
