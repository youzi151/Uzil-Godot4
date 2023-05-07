
## TagSearch.Inst 標籤檢索
## 
## 提供 進階標籤 的 檢索系統. [br]
## 持有 具有 tag索引與對應資料 的 集合. [br]
##

# Variable ===================

## 設定
var config = null :
	get : return self._config
var _config = null

## 目標資料:標籤 庫
var target_to_tags := {}

## 是否已經快取
var _is_cached := false
## 快取 目標資料:標籤 鍵 (目標資料)
var _cache_target_to_tags_keys := []
## 快取 目標資料:標籤 值 (標籤)
var _cache_target_to_tags_values := []

# GDScript ===================

func _init (cfg) :
	self._config = cfg

# Public =====================

## 設置 資料
func set_data (target, tags : Array) :
	var total_tag_datas := []
	for tag in tags :
		var tag_datas = self.parse_tags(tag)
		total_tag_datas.append_array(tag_datas)
		
	self.target_to_tags[target] = total_tag_datas
	self._is_cached = false

## 以字串搜尋
func search (search_str : String) -> Dictionary :
	var search_data = self.parse_search_str(search_str)
	return self.search_tags(search_data.tags)

## 以Tags搜尋
func search_tags (to_search_tags : Array) -> Dictionary :
	
	# 結果 目標資料:標籤資料列表
	var result_target_to_tag_datas := {}
	# 排除 目標資料
	var exclude_target := {}
	
	# 若 沒有 快取 則
	if self._is_cached == false : 
		# 建立快取
		self.gen_cache()
	
	# 資料總數
	var target_and_data_size = range(self._cache_target_to_tags_keys.size())
	
	# 要查找的標籤資料
	var to_search_tag_datas := []
	# 每筆 要查找的標籤 建立 成 標籤資料
	for to_search_tag in to_search_tags :
		var tag_data = self.parse_tag(to_search_tag)
		to_search_tag_datas.push_back(tag_data)
	
	# 排序 有 負面搜尋的tag優先
	to_search_tag_datas.sort_custom(func(a, b): 
		return a.is_negative and (not b.is_negative)
	)
	
	# 每筆 要查找的標籤資料
	for each_to_search in to_search_tag_datas :
		
		# 每個 快取中的資料
		for idx in target_and_data_size :
			
			# 輪詢資料
			var each_target = self._cache_target_to_tags_keys[idx]
			var each_tags = self._cache_target_to_tags_values[idx]
			
			# 是否通過 (1:通 -1:不通過 0:忽略)
			var is_pass = 0
			
			# 若 已被排除 則 忽略
			if exclude_target.has(each_target) : continue
			
			# 若 要查找的 為 負面尋找
			if each_to_search.is_negative :
				
				# 每個 輪詢資料 的 標籤
				for each_tag in each_tags :
					# 若 ID 不同 則 忽略
					if each_to_search.id != each_tag.id : continue
					# 若 所屬 不同 則 忽略
					if not self.scope_equal(each_to_search.scope, each_tag.scope) : continue
					
					# 判定 為 不通過
					is_pass = -1
					break
			
			# 若 要查找的 為 正面尋找
			else :
				
				# 若已經被加入結果列表 則 忽略
				if result_target_to_tag_datas.has(each_target) : continue
				
				# 每個 輪詢資料 的 標籤
				for each_tag in each_tags :
					# 若 所屬 不同
					if not self.scope_equal(each_to_search.scope, each_tag.scope) : continue
					# 若 ID 不同
					if each_to_search.id != each_tag.id : continue
					
					# 判定 為 通過
					is_pass = 1
					break
			
			# 若 通過
			if is_pass == 1 :
				# 加入 結果列表
				result_target_to_tag_datas[each_target] = each_tags
				
			# 若 不通過
			elif is_pass == -1 :
				# 加入 排除列表
				exclude_target[each_target] = true
			
		
	return result_target_to_tag_datas

## 產生 快取
func gen_cache () :
	self._cache_target_to_tags_keys = self.target_to_tags.keys()
	self._cache_target_to_tags_values = self.target_to_tags.values()
	self._is_cached = true

## 解析 搜尋字串
func parse_search_str (search_str : String) -> Dictionary :
	
	# 結果 解析後的標籤資料列表
	var result_tags := []
	
	#== 對字串進行整理 ====
	
	# 正則相符結果 (重複使用)
	var matches : Array[RegExMatch]
	
	# 替換""內的空白
	matches = self._config.any_in_quotes_regex.search_all(search_str)
	if matches.size() > 0 :
		for each in matches :
			var raw = each.get_string(0)
			var inner = each.get_string(1)
			var to_replace = inner.replace(" ", self._config.temp_replace_space_char)
			search_str = search_str.replace(raw, to_replace)
	
	# 去除"-"後空白
	matches = self._config.no_space_behind_negative_symbol_regex.search_all(search_str)
	if matches.size() > 0 :
		for each in matches :
			search_str = search_str.replace(each.get_string(), "-")
	
	# 去除","前後空白
	matches = self._config.no_space_around_group_symbol_regex.search_all(search_str)
	if matches.size() > 0 :
		for each in matches :
			search_str = search_str.replace(each.get_string(), ",")
		
	# 去除":"前後空白
	matches = self._config.no_space_around_scope_symbol_regex.search_all(search_str)
	if matches.size() > 0 :
		for each in matches :
			search_str = search_str.replace(each.get_string(), ":")
	
	# 括號 () 中的
	matches = self._config.search_str_group_regex.search_all(search_str)
	if matches.size() > 0 :
		for each in matches :
			var raw = each.get_string(0)
			var tag_str = each.get_string(1)
			
			tag_str = self._without_begin_end_space(tag_str)
			
			var tags = self.parse_tags(tag_str)
			for tag in tags :
				result_tags.push_back(tag)
			
			search_str = search_str.replace(raw, " ")
	
	# 以 空格 分隔 視為不同的標籤
	var groups_with_space = search_str.split(" ", false)
	
	# 每個 標籤字串
	for tag_str in groups_with_space :
		
		# 解析 標籤資料(可複數)
		var tags = self.parse_tags(tag_str)
		# 加入 結果 中
		for tag in tags :
			result_tags.push_back(tag)
	
	return {
		"tags": result_tags
	}

## 解析 標籤
func parse_tag (tag_or_tag_str) -> Dictionary :
	if typeof(tag_or_tag_str) != TYPE_STRING : return tag_or_tag_str
	var tags = self.parse_tags(tag_or_tag_str)
	if tags.size() == 0 : return tag_or_tag_str
	return tags[0]

## 解析 標籤 (可複數)
func parse_tags (tag_str : String) -> Array :
	
	# 去除頭尾空白
	tag_str = self._without_begin_end_space(tag_str)
	
	
	# 所屬
	var scope
	# 屬性
	var attr
	# 是否 為 負面搜尋
	var is_negative = false
	
	# 是否 負面
	if tag_str.begins_with("-") :
		is_negative = true
		tag_str = tag_str.right(-1)
	
	# 拆出 屬性
	if tag_str.find("/") != -1 :
		var parts = tag_str.split("/", true, 1)
		attr = parts[0]
		tag_str = parts[1]
	
	# 拆出 所屬
	if tag_str.find(":") != -1 :
		var parts = Array(tag_str.split(":"))
		tag_str = parts.pop_back()
		scope = ":".join(parts)
	
	# 拆出 複數ID
	var id_list := []
	if tag_str.find(",") != -1 :
		var matches = self._config.tag_str_group_regex.search_all(tag_str)
		for each in matches :
			var tag = self._without_begin_end_space(each.get_string())
			id_list.push_back(tag)
	else :
		id_list.push_back(tag_str)
	
	# 標籤資料 列表
	var tag_data_list := []
	
	# 每個ID
	for each_id in id_list :
		# 加入為一筆標籤資料
		tag_data_list.push_back({
			"id":each_id.replace(self._config.temp_replace_space_char, " "),
			"scope":scope,
			"attr":attr,
			"is_negative":is_negative
		})
	
	return tag_data_list

## 是否具有屬性
func is_attr (tag, attr) -> bool :
	var tag_data = self.parse_tag(tag)
	return tag_data.attr.find(attr) != -1

## 所屬是否相等
func scope_equal (scope_a, scope_b) -> bool :
	# null 為 任意
	if scope_a == null or scope_b == null : return true
	return scope_a == scope_b

## 去除頭尾空白
func _without_begin_end_space (text) -> String :
	var regex_match = self._config.no_begin_end_space_regex.search(text)
	if regex_match == null : return text
	return regex_match.get_string()
