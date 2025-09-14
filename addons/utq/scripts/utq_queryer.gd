## UTQ Queryer
## 
## UTQ 對資料進行標籤查詢
##

# Variable ===================

var inst

# GDScript ===================

## 初始化
func _init (_inst) :
	self.inst = _inst

# Public =====================

## 主要查詢介面
func query (query_str: String) -> Dictionary :
	if self.inst.is_debug : G.print("query: %s" % [query_str])
	
	# 解析查詢字串
	var query_request = self.parse_query_str(query_str)
	var type_to_group_to_tags = query_request["type_to_group_to_tags"]
	
	var result := {}
	
	# 每筆資料
	for target in self.inst.target_to_data:
		var target_tags = self.inst.target_to_data[target]
		var is_match = self.is_match_tags(target_tags, type_to_group_to_tags)
		if self.inst.is_debug : G.print("check target: %s %s, is_match: %s" % [target, target_tags, is_match])
		if is_match :
			result[target] = true
	
	return result

## 解析查詢字串
func parse_query_str (query_str: String) -> Dictionary :
	var raw_str : String = query_str
	query_str = self.get_clean_query_str(query_str)
	
	# 找到所有中括號位置
	var matches = self.inst.cfg.bracket_regex.search_all(query_str)
	var bracket_positions := []
	
	# 取得所有中括號內容
	for match in matches :
		var start : int = match.get_start()
		var prev : int = start - 1
		var end : int = match.get_end()
		var content : String = match.get_string(1)
		var prefix : String = query_str[prev] if prev >= 0 else ""
		
		var info := [prefix, start, end, content]
		bracket_positions.push_back(info)
	
	var type_to_group_to_tags := {}
	var query_request := {
		"type_to_group_to_tags": type_to_group_to_tags,
	}
	
	var current_pos := 0
	
	for info in bracket_positions:
		# 1. 解析 中括號前的非中括號片段
		if info[1] > current_pos:
			var before_text : String = query_str.substr(current_pos, info[1] - current_pos)
			var before_parts = before_text.split(self.inst.cfg.seperator_tag, false)
			for part in before_parts:
				var tag_datas := self.parse_tags_str(part)
				self.add_tag_datas_to(type_to_group_to_tags, tag_datas, false)
		
		# 2. 解析 中括號片段
		var prefix : String = info[0]
		var content : String = info[3]
		var before_parts = content.split(self.inst.cfg.seperator_tag, false)
		for part in before_parts:
			var tag_datas := self.parse_tags_str(prefix + part)
			self.add_tag_datas_to(type_to_group_to_tags, tag_datas, true)
		
		# 3. 移動到下一個位置
		current_pos = info[2]
	
	# 4. 處理最後剩餘的非中括號片段
	if current_pos < query_str.length() :
		var remaining_text = query_str.substr(current_pos)
		var remaining_parts = remaining_text.split(self.inst.cfg.seperator_tag, false)
		for part in remaining_parts:
			var tag_datas := self.parse_tags_str(part)
			self.add_tag_datas_to(type_to_group_to_tags, tag_datas, false)
	
	return query_request

## 解析 標籤字串 為 標籤資料
func parse_tags_str (tags_str: String, is_exclude_without := false) -> Array :
	var tag_list := []
	
	# 所屬
	var scope := ""
	# 屬性
	var attr := ""
	# 搜尋類型
	var search_type := 2 # 預設為必須
	
	var after_prefix_idx : int = -1
	
	# 搜尋類型
	var prefix : String = tags_str[0]
	if prefix == self.inst.cfg.prefix_without :
		if tags_str[1] == self.inst.cfg.prefix_without :
			search_type = self.inst.cfg.SearchType.EXCLUDE
			after_prefix_idx -= 1
		else :
			search_type = self.inst.cfg.SearchType.WITHOUT
	elif prefix == self.inst.cfg.prefix_tolerant :
		search_type = self.inst.cfg.SearchType.TOLERANT
	elif prefix == self.inst.cfg.prefix_anyone :
		search_type = self.inst.cfg.SearchType.ANYONE
	
	if search_type != self.inst.cfg.SearchType.REQUIRED :
		tags_str = tags_str.right(after_prefix_idx)
	
	# 拆出 屬性
	var parts := []
	parts = tags_str.split(self.inst.cfg.seperator_attr, true, 1)
	if parts.size() > 1 :
		attr = parts[0]
		tags_str = parts[1]
	
	# 拆出 所屬
	parts = tags_str.split(self.inst.cfg.seperator_scope, true)
	if parts.size() > 1 :
		tags_str = parts.pop_back()
		scope = self.inst.cfg.seperator_scope.join(parts)
	
	var sub_tags := []
	
	# 復原 臨時空白字元 為 正常空白字元
	tags_str = tags_str.replace(self.inst.cfg.temp_space_char, " ")
	
	# 拆出 "" 群
	if tags_str.find("\"") != -1 :
		var matches = self.inst.cfg.any_in_quotes_regex.search_all(tags_str)
		if matches.size() > 0 :
			for each in matches :
				var raw = each.get_string(0)
				var inner = each.get_string(1)
				tags_str = tags_str.replace(raw, "")
				sub_tags.push_back(inner)
	
	# 拆出 複數值
	parts = tags_str.split(self.inst.cfg.separator_tag_same_scope, false)
	for each in parts :
		sub_tags.push_back(each)
	
	# 每個 值
	for each_tag in sub_tags :
		var tag = self.inst.UTQ.Tag.new()
		
		var val : String = each_tag
		if each_tag.begins_with(self.inst.cfg.wildcard_and_except) :
			var splited : Array = each_tag.split(self.inst.cfg.wildcard_except, false)
			val = splited.pop_front()
			tag.wild_excepts = splited
		
		tag.val = val
		tag.scope = scope
		tag.attr = attr
		tag.search_type = search_type
		# 加入為一筆標籤資料
		tag_list.push_back(tag)
	
	return tag_list

## 取得 簡潔 搜尋字串
func get_clean_query_str (query_str: String) -> String :
	# 正則相符結果 (重複使用)
	var matches : Array[RegExMatch]
	
	# 尋找任意""內的內容 並 替換空白為自定義字元
	matches = self.inst.cfg.any_in_quotes_regex.search_all(query_str)
	if matches.size() > 0 :
		for each in matches :
			var raw = each.get_string(0)
			var inner = each.get_string(1)
			var to_replace = inner.replace(" ", self.inst.cfg.temp_space_char)
			query_str = query_str.replace(inner, to_replace)
	
	# 移除多餘空白
	matches = [null]
	while matches.size() > 0 :
		matches = self.inst.cfg.redundant_space_regex.search_all(query_str)
		var is_changed := false
		
		for each_match in matches :
			var raw : String = each_match.get_string(0)
			var trimed : String = each_match.get_string(1)
			if raw != trimed :
				query_str = query_str.replace(raw, trimed)
				is_changed = true
		
		if not is_changed : break
	
	return query_str

## 檢查是否符合 標籤需求
func is_match_tags (target_tags: Array, type_to_group_to_tags: Dictionary) -> bool :
	
	var is_positive_match := false
	
	# 1. 檢查強制排除標籤
	if type_to_group_to_tags.has(self.inst.cfg.SearchType.EXCLUDE) :
		var exclude_tags = type_to_group_to_tags[self.inst.cfg.SearchType.EXCLUDE][0]
		if exclude_tags.size() > 0 :
			for tag in exclude_tags:
				if self.has_matching_tag(target_tags, tag):
					if self.inst.is_debug : G.print("%s not exclude %s" % [target_tags, tag])
					return false
	
	# 2. 檢查寬容標籤
	if type_to_group_to_tags.has(self.inst.cfg.SearchType.TOLERANT) :
		var tolerant_tags = type_to_group_to_tags[self.inst.cfg.SearchType.TOLERANT][0]
		if tolerant_tags.size() > 0:
			for tag in tolerant_tags:
				if self.has_matching_tag(target_tags, tag):
					return true
	
	# 3. 檢查排除標籤
	if type_to_group_to_tags.has(self.inst.cfg.SearchType.WITHOUT) :
		var without_tags = type_to_group_to_tags[self.inst.cfg.SearchType.WITHOUT][0]
		if without_tags.size() > 0 :
			for tag in without_tags:
				if self.has_matching_tag(target_tags, tag):
					if self.inst.is_debug : G.print("%s not without %s" % [target_tags, tag])
					return false
	
	# 4. 檢查必須標籤
	if type_to_group_to_tags.has(self.inst.cfg.SearchType.REQUIRED) :
		var required_tags = type_to_group_to_tags[self.inst.cfg.SearchType.REQUIRED][0]
		if required_tags.size() > 0 :
			is_positive_match = true
			for tag in required_tags:
				if not self.has_matching_tag(target_tags, tag):
					if self.inst.is_debug : G.print("%s not has %s" % [target_tags, tag])
					return false
	
	# 5. 檢查任一標籤
	if type_to_group_to_tags.has(self.inst.cfg.SearchType.ANYONE) :
		var anyone_tags_groups = type_to_group_to_tags[self.inst.cfg.SearchType.ANYONE]
		# 每個群組
		for anyone_tags in anyone_tags_groups :
			if anyone_tags.size() == 0 : continue
			else : is_positive_match = true
			
			var has_anyone_match_in_group = false
			# 每個標籤
			for tag in anyone_tags:
				# 若任一標籤有符合 則 此群組通過
				if self.has_matching_tag(target_tags, tag) :
					has_anyone_match_in_group = true
					break
			# 若此群組沒有任一標籤符合 則 此查詢不通過
			if not has_anyone_match_in_group:
				if self.inst.is_debug : G.print("%s does not has any in %s" % [target_tags, anyone_tags])
				return false
	
	return is_positive_match

## 是否 標籤列表中 有與 標籤資料 相符的標籤
func has_matching_tag (tag_datas: Array, tag_data) -> bool :
	for each in tag_datas :
		
		if not tag_data.scope.is_empty() :
			if tag_data.scope != self.inst.cfg.wildcard :
				if each.scope != tag_data.scope : continue
		
		if tag_data.val != self.inst.cfg.wildcard : 
			if each.val != tag_data.val : continue
		
		if each.val in tag_data.wild_excepts : continue
		
		return true

	return false

## 將 標籤資料 加入 目標資料表 (是否為群組)
func add_tag_datas_to (type_to_group_to_tags: Dictionary, tag_datas: Array, is_group: bool) :
	
	if is_group :
		
		# 暫時 類型:當前群組標籤列表
		var tmp_typed_to_cur_group_tags := {}
		
		for tag_data in tag_datas:
			# 若 已有 暫存此類型的當前群組標籤列表
			if tmp_typed_to_cur_group_tags.has(tag_data.search_type) :
				tmp_typed_to_cur_group_tags[tag_data.search_type].push_back(tag_data)
				continue
			
			# 群組標籤
			var group_tags := [tag_data]
			
			# 若 目標資料表 沒有此搜尋類型
			if not type_to_group_to_tags.has(tag_data.search_type) :
				# 加入 目標資料表 (空[]: 預設 非group tags)
				type_to_group_to_tags[tag_data.search_type] = [[], group_tags]
			# 若 目標資料表 有此搜尋類型
			else :
				type_to_group_to_tags[tag_data.search_type].push_back(group_tags)
			
			# 暫存 當前群組標籤列表
			tmp_typed_to_cur_group_tags[tag_data.search_type] = group_tags
		
	else :
		
		for tag_data in tag_datas :
			if not type_to_group_to_tags.has(tag_data.search_type) :
				type_to_group_to_tags[tag_data.search_type] = [[tag_data]]
			else :
				var ungroup_tags : Array = type_to_group_to_tags[tag_data.search_type][0]
				ungroup_tags.push_back(tag_data)
