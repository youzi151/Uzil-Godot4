
## UserSave.Strat.File 用戶存檔 策略 檔案
##
## 以 檔案 存取各種存檔資料.
## 

# Variable ===================

var version : String = ""

# GDScript ===================

func _init (format_version_str) :
	self.version = format_version_str

# Extends ====================

# Public =====================

## 讀取
func read (inst, file_path : String, routes : Array, options : Dictionary) :
	
	# 總結果
	var results : Dictionary = {}
	
	# 檔案路徑 與 快取
	var _read_path_to_cache : Dictionary = {}
	
	# 每個 路徑
	for route in routes :
		# 結果
		var result = null
		# 檔案內容
		var file_content = null
		# 常規路徑
		var regular_path : String = inst._get_regular_path(file_path)
		# 路徑
		var parsed_route : Dictionary = {}
		var route_parts : Array = []
		# 若 路徑 不為空 則 解析
		if route != "" :
			parsed_route = inst._parse_route(route)
			route_parts = parsed_route.routes
		
		# 若 快取 存在 則 取用
		if _read_path_to_cache.has(regular_path) :
			file_content = self._make_standalone(_read_path_to_cache[regular_path])
		# 若 實例快取 存在 則 取用
		elif inst._is_allow_cache(options) and inst._path_to_cache.has(regular_path) :
			file_content = self._make_standalone(inst._path_to_cache[regular_path])
		# 否則 讀取
		else :
			file_content = self._read_file(regular_path)
			inst._path_to_cache[regular_path] = file_content
			_read_path_to_cache[regular_path] = file_content
		
		# 若為 字典 則 從路徑中取得內容
		if file_content is Dictionary :
			result = inst._get_content_val(file_content, route_parts, options)
		# 若為 非字典 則 直接視為內容
		else :
			result = file_content
		
		# 若 尚未取得 值
		if result == null :
			
			# 是否允許模板
			var is_allow_templates : bool = true
			if "allow_templates" in options :
				is_allow_templates = options["allow_templates"]
			
			# 若 允許模板
			if is_allow_templates : 
				
				# 模板內容
				var template_content
				
				# 開始嘗試 非常規方法
				
				# 路徑格式
				var path_format : String = inst.setting.get_path_format()
				var path_formated : String = ""
				# 路徑變數
				var path_var : Dictionary = inst.setting.get_path_var()
				# 路徑變數 加入 檔案
				path_var["FILE"] = file_path
				
				# 每個 模板目錄 (從末端)
				var templates : Array = inst.setting.template_folders
				for idx in range(templates.size()-1, -1, -1) :
					var each = templates[idx]
					
					# 取代 路徑變數中 目錄 為 模板目錄
					path_var["FOLDER"] = each
					path_formated = path_format.format(path_var)
					
					# 讀取模板檔案
					template_content = self._read_file(path_formated)
					# 若 不存在 則 下一個
					if template_content == null : continue
					
					# 加入 至 快取
					_read_path_to_cache[path_formated] = template_content
					
					# 若為 字典 則 從路徑中取得內容
					if template_content is Dictionary :
						result = inst._get_content_val(template_content, route_parts, options)
					# 若為 非字典 則 直接視為內容
					else :
						result = template_content
					
					# 若 已有取得結果 則 跳出
					if result != null : break
		
		# 加入 至 總結果
		results[route] = result
	
	return results


## 寫入
func write (inst, file_path : String, route_to_val : Dictionary, options := {}) :
	
	# 要寫入的內容
	var to_write = null
	
	# 常規路徑
	var regular_path : String = inst._get_regular_path(file_path)
	
	# 現有內容
	var exist_content = self._read_file(regular_path)
	# 若 現有內容 存在 且 為 字典
	if exist_content != null and exist_content is Dictionary :
		# 設為 要寫入的內容 (作為基底)
		to_write = exist_content
	
	# 若 為 完整內容
	if options.has("full_content") and options["full_content"] :
		# 若 含有空鍵
		if route_to_val.has("") :
			# 取出 為 要寫入的內容
			to_write = route_to_val[""]
			route_to_val.erase("")
	
	# 若 有存在 要寫入的內容
	if route_to_val.size() > 0 :
		# 若 基底不為字典 則 取代基底為字典
		if not (to_write is Dictionary) :
			to_write = {}
		
		# 每個 路徑:值
		for route in route_to_val :
			# 路徑 解析
			var parsed_route : Dictionary = {}
			var route_parts : Array = []
			if route != "" :
				parsed_route = inst._parse_route(route)
				route_parts = parsed_route.routes
			# 設置 到 要寫入內容的路徑中
			inst._set_content_val(to_write, route_parts, route_to_val[route], options)
	
	# 檢查 資料夾 是否存在
	var dir_path = regular_path.get_base_dir()
	# 若 不存在 則 建立
	if not DirAccess.dir_exists_absolute(dir_path) :
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	# 開啟 檔案
	var file : FileAccess = FileAccess.open(regular_path, FileAccess.WRITE)
	
	# 保存 格式版本
	file.store_var(self.version)
	# 保存 內容
	file.store_var(to_write, false)
	# 關閉並寫入 檔案
	file.close()
	
	# 記錄到快取
	inst._path_to_cache[regular_path] = self._make_standalone(to_write)

## 解析路徑
func parse_route (route : String) -> Dictionary :
	var splited : Array = route.split("/", true)
	if splited[0] == "" : splited.pop_front()
	return {
		"routes" : splited,
	}

# Private ====================

func _make_standalone (file_content) :
	match typeof(file_content) :
		TYPE_ARRAY, TYPE_DICTIONARY :
			return file_content.duplicate(true)
		_ :
			return file_content

func _read_file (path : String) :
	
	if not FileAccess.file_exists(path) : return null
	
	# 開啟檔案
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	# 若 檔案不存在 則 返回 空
	if file == null :
		return null
	
	# 格式版本
	var format_version = file.get_var(false)
	
	# 檢查版本 並 警告 與 處理
	# TODO
	#G.print(format_version)
	
	# 內容
	var content = file.get_var(false)
	
	# 返回
	return content
