
## TagQ.Inst 標籤檢索
## 
## 提供 進階標籤 的 檢索系統. [br]
## 持有 具有 tag索引與對應資料 的 集合. [br]
##

# Variable ===================

var TagData

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

func _init (cfg = null) :
	var TagQ = UREQ.acc(&"Uzil:Basic.TagQ")
	
	if cfg == null : cfg = TagQ.default_config
	
	self._config = cfg
	self.TagData = TagQ.TagData

# Public =====================

func clear () :
	self._is_cached = false
	self.target_to_tags.clear()
	self._cache_target_to_tags_keys.clear()
	self._cache_target_to_tags_values.clear()

## 設置 標籤
func set_tags (target, tags: Array) :
	var total_tag_datas := []
	for tag in tags :
		var tag_datas = self.parse_tags(tag)
		total_tag_datas.append_array(tag_datas)
	
	self.set_datas(target, total_tag_datas)

## 設置 資料
func set_datas (target, tag_datas: Array) :
	var verified := []
	for each in tag_datas :
		if each.get_script() == self.TagData :
			verified.push_back(each)
	self.target_to_tags[target] = verified
	self._is_cached = false

## 取得 資料
func get_datas (target) :
	if not self.target_to_tags.has(target) : return null
	var tag_datas : Array = self.target_to_tags[target]
	return tag_datas.duplicate()

## 以字串搜尋
func search (search_str: String) -> Dictionary :
	var search_data = self.parse_search_str(search_str)
	return self.search_tags(search_data.tags)

## 以Tags搜尋
func search_tags (to_search_tags: Array) -> Dictionary :
	
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
	var to_search_negative := []
	var to_search_optional := []
	var to_search_positive := []
	
	var tag_datas := []
	
	# 每筆 要查找的標籤 建立 成 標籤資料
	for to_search_tag in to_search_tags :
		if to_search_tag is String :
			tag_datas.append_array(self.parse_tag(to_search_tag))
		else : 
			tag_datas.push_back(to_search_tag)
			
	for tag_data in tag_datas :
		if tag_data.scope.is_empty() :
			tag_data.scope = self.config.SIGN_ANY
		
		match tag_data.search_type :
			-1 : 
				to_search_negative.push_back(tag_data)
			0 :
				to_search_optional.push_back(tag_data)
			_ :
				to_search_positive.push_back(tag_data)
	
	# 每個 快取中的輪詢資料
	for idx in target_and_data_size :
		
		# 輪詢資料
		var each_target = self._cache_target_to_tags_keys[idx]
		var each_tags = self._cache_target_to_tags_values[idx]
		
		var is_target_pass := 0
		
		# 每筆 要查找的 負面標籤
		for each_to_search in to_search_negative :
			# 每個 輪詢資料 標籤
			for each_tag in each_tags :
				# 若 ID 不同 則 忽略
				if not self.id_equal(each_tag.id, each_to_search.id) : continue
				# 若 所屬 不同 則 忽略
				if not self.scope_equal(each_tag.scope, each_to_search.scope) : continue
				# 若 都相同 則 標記 不通過
				is_target_pass = -1
				break
			
			# 若 已有結果 則 跳出
			if is_target_pass != 0 : break
		
		# 若 未有結果 則 
		if is_target_pass == 0 :
			# 每筆 要查找的 可選標籤
			for each_to_search in to_search_optional :
				# 每個 輪詢資料 標籤
				for each_tag in each_tags :
					# 若 ID 不同 則 忽略
					if not self.id_equal(each_tag.id, each_to_search.id) : continue
					# 若 所屬 不同 則 忽略
					if not self.scope_equal(each_tag.scope, each_to_search.scope) : continue
					
					# 若 都相同 則 標記 通過
					is_target_pass = 1
					break
				
				# 若 已有結果 則 跳出
				if is_target_pass != 0 : break
			
		
		# 若 未有結果 則 
		if is_target_pass == 0 :
			# 每筆 要查找的 必要標籤
			for each_to_search in to_search_positive :
				
				is_target_pass = -1
				
				# 每個 輪詢資料 標籤
				for each_tag in each_tags :
					# 若 ID 不同
					if not self.id_equal(each_tag.id, each_to_search.id) : continue
					# 若 所屬 不同
					if not self.scope_equal(each_to_search.scope, each_tag.scope) : continue
				
					# 判定 為 通過
					is_target_pass = 1
					break
				
				# 若 任一個 必要標籤 不通過 則 跳出
				if is_target_pass == -1 : break
			
		if is_target_pass == 1 :
			# 加入 結果列表
			result_target_to_tag_datas[each_target] = each_tags
		
	return result_target_to_tag_datas

## 產生 快取
func gen_cache () :
	self._cache_target_to_tags_keys = self.target_to_tags.keys()
	self._cache_target_to_tags_values = self.target_to_tags.values()
	self._is_cached = true

## 解析 搜尋字串
func parse_search_str (search_str: String) -> Dictionary :
	
	# 結果 解析後的標籤資料列表
	var result_tags := self.parse_tags(search_str)
	
	return {
		"tags": result_tags
	}

## 解析 標籤 (可複數)
func parse_tags (to_parse_str: String) -> Array :
	
	# 正則相符結果 (重複使用)
	var matches : Array[RegExMatch]
	
	# 替換""內的空白
	matches = self._config.any_in_quotes_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each in matches :
			var raw = each.get_string(0)
			var inner = each.get_string(1)
			var to_replace = inner.replace(" ", self._config.temp_replace_space_char)
			to_parse_str = to_parse_str.replace(inner, to_replace)
	
	# 去除"-"後空白
	matches = self._config.no_space_behind_negative_symbol_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each in matches :
			to_parse_str = to_parse_str.replace(each.get_string(), "-")
			
	# 去除"+"後空白
	matches = self._config.no_space_behind_positive_symbol_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each in matches :
			to_parse_str = to_parse_str.replace(each.get_string(), "+")
		
	# 去除":"前後空白
	matches = self._config.no_space_around_scope_symbol_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each in matches :
			to_parse_str = to_parse_str.replace(each.get_string(), ":")
	
	# 去除","前後空白
	matches = self._config.no_space_around_group_symbol_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each in matches :
			to_parse_str = to_parse_str.replace(each.get_string(), ",")
	
	# 初步分割結果
	var splited_list := []
	
	# 括號 () 中的
	matches = self._config.search_str_group_regex.search_all(to_parse_str)
	if matches.size() > 0 :
		for each_match in matches :
			var raw = each_match.get_string(0)
			var each_str = each_match.get_string(1)
			
			# 從原本的搜尋字串中 去除 此結果
			to_parse_str = to_parse_str.replace(raw, " ")
			
			# 以 空白 分隔 視為不同的標籤
			var groups_with_space = each_str.split(" ", false)
			for each_group in groups_with_space :
				splited_list.push_back(each_group)
				
	# 以 空白 分隔 視為不同的標籤分群
	var groups_with_space = to_parse_str.split(" ", false)
	# 每個 分群
	for each_group in groups_with_space :
		splited_list.push_back(each_group)
	
	# 標籤資料 列表
	var tag_data_list := []
	
	# 解析 每個標籤分群
	for tags_str in splited_list :
		tag_data_list.append_array(self.parse_tag(tags_str))
	return tag_data_list


## 解析 標籤
func parse_tag (tags_str: String) -> Array :
	var tag_data_list := []
	
	var matches : Array[RegExMatch]
	
	# 去除頭尾空白
	tags_str = self._without_begin_end_space(tags_str)
	
	# 所屬
	var scope := ""
	# 屬性
	var attr := ""
	# 搜尋類型
	var search_type = 1
	
	# 搜尋類型
	if tags_str.begins_with("+") :
		search_type = 0
		tags_str = tags_str.right(-1)
	elif tags_str.begins_with("-") :
		search_type = -1
		tags_str = tags_str.right(-1)
	
	# 拆出 屬性
	if tags_str.find("/") != -1 :
		var parts = tags_str.split("/", true, 1)
		attr = parts[0]
		tags_str = parts[1]
	
	# 拆出 所屬
	if tags_str.find(":") != -1 :
		var parts = Array(tags_str.split(":"))
		tags_str = parts.pop_back()
		scope = ":".join(parts)
	
	var tag_list := []
	
	# 拆出 "" 群
	if tags_str.find("\"") != -1 :
		matches = self._config.any_in_quotes_regex.search_all(tags_str)
		if matches.size() > 0 :
			for each in matches :
				var raw = each.get_string(0)
				var inner = each.get_string(1)
				tags_str = tags_str.replace(raw, ",")
				tag_list.push_back(inner)
	
	# 拆出 複數ID
	if tags_str.find(",") != -1 :
		matches = self._config.tag_str_group_regex.search_all(tags_str)
		for each in matches :
			tag_list.push_back(each.get_string())
	else :
		tag_list.push_back(tags_str)
		
	# TODO : i18n
	
	# 每個ID
	for each_tag in tag_list :
		var data = self.TagData.new()
		data.id = each_tag.replace(self._config.temp_replace_space_char, " ")
		data.scope = scope
		data.attr = attr
		data.search_type = search_type
		# 加入為一筆標籤資料
		tag_data_list.push_back(data)
	
	return tag_data_list


## 是否具有屬性
func is_attr (tag, attr) -> bool :
	var tag_data = self.parse_tag(tag)
	return tag_data.attr.find(attr) != -1

## 辨識ID是否相等
func id_equal (id_a: String, id_b: String) -> bool :
	if id_a == self.config.SIGN_ANY or id_b == self.config.SIGN_ANY : return true
	return id_a == id_b

## 所屬是否相等
func scope_equal (scope_a: String, scope_b: String) -> bool :
	if scope_a == self.config.SIGN_ANY or scope_b == self.config.SIGN_ANY : return true
	return scope_a == scope_b

## 去除頭尾空白
func _without_begin_end_space (text: String) -> String :
	var regex_match = self._config.no_begin_end_space_regex.search(text)
	if regex_match == null : return text
	return regex_match.get_string()
