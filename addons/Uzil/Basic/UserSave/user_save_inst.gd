
## UserSave.Inst 用戶存檔 實體
##
## 以 設定檔 的 路徑, 存取各種存檔資料.
## 

# Variable ===================

## 策略
var strat

## 配置
var setting
var _setting_update_listener

## 基底路徑
var _base_path : String = ""

## 路徑:快取
var _path_to_cache := {}

# GDScript ===================

func _init (strat, setting) :
	self.set_strat(strat)
	self.set_setting(setting)
	self._base_path = self.setting.get_path_format()

# Extends ====================

# Public =====================

## 設置 策略
func set_strat (_strat) :
	self.strat = _strat
	return self

## 設置 設置
func set_setting (_setting) :
	# 移除原先
	if self.setting != null :
		self.setting.on_update.off(self._setting_update_listener)
	
	self.setting = _setting
	
	# 加入偵聽 當設定更新
	self._setting_update_listener = self.setting.on_update.on(self._on_setting_update)
	
	return self


## 讀取 字典 值 (若可以則優先讀取快取)
# 考慮到穩定性, 不考慮 非字典中值路徑 的狀況
func read (path : String, route : String = "", options := {}) :
	var content = self.reads(path, [route], options)
	if content == null : return null
	if not content.has(route) : return null
	return content[route]

## 讀取 字典 值 以 多個路徑
func reads (file_path : String, routes : Array, options := {}) :
	var readed = self.strat.read(self, file_path, routes, options)
	return readed

## 寫入 字典 值
# 考慮到穩定性, 不考慮 非字典中值路徑 的狀況
func write (file_path : String, route : String, val, options := {}) :
	self.writes(file_path, {route:val}, options)

## 寫入 字典 值 以 多個路徑:值
func writes (file_path : String, route_to_val : Dictionary, options := {}) :
	# 若 只有一個 且為 空鍵 則 標記為 整個寫入
	if route_to_val.size() == 1 and route_to_val.has("") :
		options["full_content"] = true
	self.strat.write(self, file_path, route_to_val, options)

# Private ====================

## 取得 要使用的路徑
func _get_regular_path (file_path) -> String :
	var path_var : Dictionary = self.setting.get_path_var()
	path_var["FILE"] = file_path
	return self._base_path.format(path_var).simplify_path()

## 是否使用快取
func _is_allow_cache (options : Dictionary) -> bool :
	if "allow_cache" in options :
		return options["allow_cache"]
	elif self.setting.flags.has("allow_cache") :
		return self.setting.flags["allow_cache"]
	return true

## 取得 內容 值
func _get_content_val (file_content : Dictionary, route_parts : Array, options : Dictionary) :
	# 若 路徑不存在 則 返回 本身
	if route_parts.size() == 0 : 
		return file_content
	
	# 若 內容類型 非 字典
	if not (file_content is Dictionary) : 
		G.print("[Uzil.Basic.UserData.Inst._get_content_val] file_content is not dictionary")
		return null
	
	# 當前位置
	var curr = file_content
	# 每個 值路徑
	for each in route_parts :
		# 若 下一個 路徑 非 字典 則 返回 空
		if not (curr is Dictionary) : return null
		# 若 下一個 路徑不存在 則 返回 空
		if not curr.has(each) : return null
		# 指定 至 下一位置
		curr = curr[each]
	
	return curr

## 設置 內容 值
func _set_content_val (file_content : Dictionary, route_parts : Array, val, options : Dictionary) :
	
	# 是否為清除
	var is_erase : bool = val == null
	
	# 當前
	var curr = file_content
	var parent : Dictionary = file_content
	
	# 值路徑
	var route_parts_size : int = route_parts.size()
	
	# 若 值路徑 有效 則 
	if route_parts_size > 0 : 
		
		# 每個 值路徑 (除了最後一個要寫入的)
		for idx in route_parts_size :
			var each_route = route_parts[idx]
			
			var is_curr_dict : bool = curr is Dictionary
			
			# 若 為 寫入
			if not is_erase :
				
				# 若 當前不是 字典
				if not is_curr_dict :
					# 設置為字典
					curr = {}
					var last_route = route_parts[idx-1]
					parent[last_route] = curr
				
				# 若 超出 最後一個值路徑 則 跳出
				if idx >= route_parts_size-1 : break
				
				# 設 上個 為 當前
				parent = curr
				
				# 若 值路徑 不存在 則
				if not curr.has(each_route) :
					# 新建立
					curr[each_route] = {}
					
				# 設 當前 為 下個
				curr = curr[each_route]
			
			# 若 為 移除
			else :
				
				# 若 值路徑 不是 dictionary 則 視為無效操作
				if not is_curr_dict : return
				
				# 若 超出 最後一個值路徑 則 跳出
				if idx >= route_parts_size-1 : break
				
				# 若 值路徑 存在 則 取用
				if curr.has(each_route) :
					# 設 上個 為 當前
					parent = curr
					curr = curr[each_route]
			
		
		# 以 指定值路徑 的 最後一個 路徑 為 鍵 設置 值
		var key = route_parts[route_parts_size-1]
		
		if not is_erase :
			curr[key] = val
		else :
			if curr.has(key) :
				curr.erase(key)

## 當 設定 更新
func _on_setting_update (_ctrlr) :
	self._base_path = _ctrlr.data["path_preformat"]
	self._path_to_cache.clear()


## 解析路徑
func _parse_route (route : String) -> Dictionary :
	if self.strat.has_method("parse_route") :
		return self.strat.parse_route(route)
	else :
		return { "routes" : route.split("/", false) }
