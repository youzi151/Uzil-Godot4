
## UserSave.Strat.Cfg 用戶存檔 策略 設定檔
##
## 以 設定檔 存取各種存檔資料.
## 

# Variable ===================

# GDScript ===================

# Extends ====================

# Public =====================

## 讀取
func read (inst, file_path : String, routes : Array, options : Dictionary) :
	# 總結果
	var results : Dictionary = {}
	
	# 檔案路徑 與 快取
	var _read_path_to_cache : Dictionary = {}
	
	# 預設 區塊
	var default_section : String = ""
	if "section" in options :
		default_section = options["section"]
	
	# 常規路徑
	var regular_path : String = inst._get_regular_path(file_path)
	
	# 每個 路徑
	for route in routes :
		# 結果
		var result = null
		# 檔案
		var cfg_file : ConfigFile = null
		# 目標內容
		var file_content
		
		# 路徑
		var parsed_route : Dictionary = {}
		var route_parts : Array = []
		# 區塊 與 鍵
		var section : String = default_section
		var key : String = ""
		
		# 若 路徑 不為空 則 解析
		if route != "" :
			parsed_route = inst._parse_route(route)
			if parsed_route.section != "" :
				section = parsed_route.section
			key = parsed_route.key
			route_parts = parsed_route.routes
		
		# 若 快取 存在 則 取用
		if _read_path_to_cache.has(regular_path) :
			cfg_file = _read_path_to_cache[regular_path]
		# 若 實例快取 存在 則 取用
		elif inst._is_allow_cache(options) and inst._path_to_cache.has(regular_path) :
			cfg_file = inst._path_to_cache[regular_path]
		# 否則 讀取
		else :
			cfg_file = self._read_file(regular_path)
			inst._path_to_cache[regular_path] = cfg_file
			_read_path_to_cache[regular_path] = cfg_file
		
		# 若 檔案存在
		if cfg_file != null :
			
			# 從中取得 目標內容
			file_content = self._get_content_from_cfg(cfg_file, section, key)
			
			# 若 目標內容存在
			if file_content != null :
				# 若 非字典 或 無指定路徑 則 直接指定為結果
				if not (file_content is Dictionary) or route_parts.size() == 0 :
					result = file_content
				# 否則 從中取得結果
				else :
					result = inst._get_content_val(file_content, route_parts, options)
		
		# 若 尚未取得 結果
		if result == null :
			
			# 是否允許模板
			var is_allow_templates : bool = true
			if "allow_templates" in options :
				is_allow_templates = options["allow_templates"]
			
			if is_allow_templates : 
				
				# 模板內容
				var template_cfg_file : ConfigFile = null
				var template_content = null
				
				# 開始嘗試 非常規方法
				
				# 路徑格式
				var path_format : String = inst.setting.get_path_format()
				var path_formated : String = ""
				# 路徑變數 加入 檔案
				var path_var : Dictionary = inst.setting.get_path_var()
				path_var["FILE"] = file_path
				
				# 每個 模板目錄 (從末端)
				var templates : Array = inst.setting.template_folders
				for idx in range(templates.size()-1, -1, -1) :
					var each : String = templates[idx]
					
					# 取代 路徑變數中 目錄 為 模板目錄
					path_var["FOLDER"] = each
					path_formated = path_format.format(path_var).simplify_path()
					
					# 讀取模板檔案
					template_cfg_file = self._read_file(path_formated)
					# 若 不存在 則 下一個
					if template_cfg_file == null : continue
					
					# 加入 快取
					_read_path_to_cache[path_formated] = template_cfg_file
					
					# 從中取得目標內容
					template_content = self._get_content_from_cfg(template_cfg_file, section, key)
					# 若 不存在 則 下一個
					if template_content == null : continue
					
					# 若 非字典 或 無指定路徑 則 直接指定為結果
					if not (template_content is Dictionary) or route_parts.size() == 0 :
						result = template_content
					# 否則 從中取得結果
					else :
						result = inst._get_content_val(template_content, route_parts, options)
						
					# 若 已有取得結果 則 跳出
					if result != null : break
		
		# 加入 至 總結果
		results[route] = result
		
	return results

## 寫入
func write (inst, file_path : String, route_to_val : Dictionary, options := {}) :

	# 常規路徑
	var regular_path : String = inst._get_regular_path(file_path)
	
	# 現有檔案
	var exist_cfg : ConfigFile = self._read_file(regular_path)
	
	# 喻社區快
	var default_section : String = ""
	if "section" in options :
		default_section = options["section"]
	
	# 每個 路徑:值
	for route in route_to_val :
		# 忽略 空鍵
		if route == "" : continue
		
		var content_val = route_to_val[route]
		
		# 路徑
		var parsed_route : Dictionary = {}
		var route_parts : Array = []
		# 區塊 與 鍵
		var section : String = default_section
		var key : String = ""
		
		# 解析路徑
		parsed_route = inst._parse_route(route)
		if parsed_route.section != "" :
			section = parsed_route.section
		key = parsed_route.key
		route_parts = parsed_route.routes
		
		# 試取得現有內容
		var exist_content = null
		if exist_cfg != null :
			if exist_cfg.has_section_key(section, key) :
				exist_content = exist_cfg.get_value(section, key)
		
		# 若 有指定路徑
		if route_parts.size() > 0 :
			# 若 無現有內容 或 非字典 則 設置取代為 空字典
			if exist_content == null or not (exist_content is Dictionary) :
				exist_content = {}
			
			# 設置 值 到 現有內容
			inst._set_content_val(exist_content, route_parts, content_val, options)
		
		# 無指定路徑 則 直接視為內容
		else :
			exist_content = content_val
			
		# 設置 現有內容 到 檔案中
		exist_cfg.set_value(section, key, exist_content)
	
	# 檢查 資料夾 是否存在
	var dir_path = file_path.get_base_dir()
	# 若 不存在 則 建立
	if not DirAccess.dir_exists_absolute(dir_path) :
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	# 加入 至 快取
	inst._path_to_cache[regular_path] = exist_cfg
	
	return exist_cfg.save(regular_path)

## 解析路徑
func parse_route (route : String) -> Dictionary :
	var section : String = ""
	var key : String = ""
	var routes : Array = []
	
	# ":" 前面 視為 區塊section 
	if route.contains(":") :
		var splited : Array = route.split(":", true, 1) 
		section = splited[0]
		route = splited[1]
	
	# "/" 分割值路徑
	if route.contains("/") :
		var splited : Array = route.split("/", true)
		key = splited[0]
		route = splited[1]
	else :
		key = route
	
	return {
		"section" : section,
		"key" : key,
		"routes" : routes,
	}


# Private ====================

## 讀取 檔案
func _read_file (full_path : String) :
	if not FileAccess.file_exists(full_path) : return null
	
	var file := ConfigFile.new()
	
	# 讀取
	var err = file.load(full_path)
	# 若 成功 則 返回
	if err == OK :
		return file
	
	#G.print("file[%s] exist ? : %s" % [full_path, FileAccess.file_exists(full_path)])
	
	return null

## 取得 內容 從 設定 中
func _get_content_from_cfg (cfg_file : ConfigFile, section : String, key : String = "") :
	
	var file_content = null
	
	# 若 指定key 則 取得
	if key != "" :
		if cfg_file.has_section_key(section, key) :
			file_content = cfg_file.get_value(section, key)
	
	# 若 無指定key 則 取得所有section中的key
	else :
		if cfg_file.has_section(section) :
			var keys : Array = cfg_file.get_section_keys(section)
			var collect : Dictionary = {}
			for each in keys :
				collect[each] = cfg_file.get_value(section, each)
			file_content = collect
	
	return file_content
