
## UserSave.Inst 用戶存檔 實體
##
## 以 設定檔 的 路徑, 存取各種存檔資料.
## 

var UserSave

# Variable ===================

## 配置
var setting

## 最終路徑
var _final_path := ""

## 檔案路徑 與 快取
var _file_path_to_cache := {}

## 是否使用快取
var is_use_cache := false 

# GDScript ===================

func _init (_setting) :
	self.UserSave = UREQ.acc("Uzil", "Basic.UserSave")
	self.set_setting(_setting)

# Extends ====================

# Public =====================

## 設置 設置
func set_setting (_setting) :
	self.setting = _setting
	if _setting._inst != self :
		_setting.set_inst(self)
	return self

## 讀取 整個
func read (path) :
	# 開啟檔案
	var file : FileAccess = FileAccess.open(self.get_file_path(path), FileAccess.READ)
	
	# 若 檔案不存在 則 返回 空
	if file == null :
		return null
	
	# 格式版本
	var format_version = file.get_var()
	
	# 檢查版本 並 警告 與 處理
	# TODO
#	G.print(format_version)
	
	# 內容
	var content = file.get_var()
	
	# 暫存內容
	self._file_path_to_cache[path] = content
	
	# 返回
	return content

## 讀取 字典 值 (若可以則優先讀取快取)
# 考慮到穩定性, 不考慮 非字典中值路徑 的狀況
func read_val (path, route) :
	# 內容
	var content
	# 若 快取中 存在 則 取用
	if self.is_use_cache and self._file_path_to_cache.has(path) :
		content = self._file_path_to_cache[path]
	# 否則 讀取
	else :
		content = self.read(path)
	# 若 內容 為 空 則 返回 空
	if content == null : return null
	
	# 若 內容類型 非 字典
	if typeof(content) != TYPE_DICTIONARY : 
		G.print("[Uzil.Basic.UserData.Inst.read_val] content is not dictionary")
		return null
		
	var curr = content
	
	# 值 路徑
	var routes = route.split("/", false)
	# 若 值路徑 無效 則 返回 空
	if routes.size() == 0 : return null
	for each in routes :
		
		# 若 下一個 路徑不存在 則 返回空
		if curr.has(each) == false :
			return null
		
		# 設 目前 為 下一個	
		curr = curr[each]
		
	return curr
		

## 寫入 整個
func write (path, content) :
	
	# 若 要寫入的內容 為 空 則 返回
	if content == null :
		content = {}
	
	# 取得 完整檔案路徑
	var file_path = self.get_file_path(path)
	
	# 檢查 資料夾 是否存在
	var dir_path = file_path.get_base_dir()
	# 若 不存在 則 建立
	if not DirAccess.dir_exists_absolute(dir_path) :
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	# 開啟 檔案
	var file : FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	# 保存 格式版本
	file.store_var(self.UserSave.FORMAT_VERSION)
	
	# 保存 內容
	file.store_var(content)
	
	# 若 內容類型 為 容器 (陣列或字典)
	var typ = typeof(content)
	if typ == TYPE_ARRAY or typ == TYPE_DICTIONARY :
		# 深複製 內容
		content = content.duplicate(true)
	
	# 保存 至 快取
	if self.is_use_cache :
		self._file_path_to_cache[path] = content

## 寫入 字典 值
# 考慮到穩定性, 不考慮 非字典中值路徑 的狀況
func write_val (path, route, val) :
	
	var is_erase := val == null
		
	# 內容
	var content
	# 若 快取 存在 則 取用
	if self.is_use_cache and self._file_path_to_cache.has(path) :
		content = self._file_path_to_cache[path]
	# 否則 讀取
	else :
		content = self.read(path)
	
	
	# 若 內容 為 空 
	if content == null:
		content = {}
		
	# 若 內容 存在
	else :
		# 若 內容類型 不為 容器
		var typ = typeof(content)
		if typ != TYPE_DICTIONARY :
			# 返回 (無法讀取值)
			G.print("[Uzil.Basic.UserData.Inst.write_val] file does not store dictionary, can not access member value")
			return
	
	# 當前
	var curr = content
	var parent = curr
	
	# 每個 值路徑 (除了最後一個要寫入的)
	var routes = route.split("/", false)
	var routes_size = routes.size()
	
	# 若 值路徑 無效 則 返回
	if routes_size == 0 : return
	
	for idx in range(routes_size) :
		var each_route = routes[idx]
		
		var is_curr_dict := typeof(curr) == TYPE_DICTIONARY
		if not is_erase :
			
			if not is_curr_dict :
				if idx == 0 :
					curr = {}
					content = curr
				else :
					curr = {}
					var last_route = routes[idx-1]
					parent[last_route] = curr
			
			# 若 超出 最後一個值路徑 則 跳出
			if idx >= routes_size-1 : break
			
			# 設 上個 為 當前
			parent = curr
			
			# 若 值路徑 不存在 則
			if not curr.has(each_route) :
				# 新建立
				curr[each_route] = {}
				
			# 設 當前 為 下個
			curr = curr[each_route]
				
		else :
			
			# 若 是移除 且 值路徑 又不是 dictionary 則 視為無效操作
			if not is_curr_dict : return
			
			# 若 超出 最後一個值路徑 則 跳出
			if idx >= routes_size-1 : break
			
			# 若 值路徑 存在 則 取用
			if curr.has(each_route) :
				# 設 上個 為 當前
				parent = curr
				curr = curr[each_route]
		
	
	# 以 指定值路徑 的 最後一個 路徑 為 鍵 設置 值
	var key = routes[routes_size-1]
	
	if not is_erase :
		curr[key] = val
	else :
		if curr.has(key) :
			curr.erase(key)
	
	# 寫入 內容
	self.write(path, content)
	

## 取得 要使用的路徑
func get_file_path (path) -> String :
	return self._final_path.replace("%FILE%", path)

# Private ====================

## 更新 總路徑
func _update_path () :
	var sub_path = self.setting.get_sub_path()
	var full_path = self.setting.get_full_path()
#	G.print("full[%s], sub[%s]" % [full_path, sub_path])
	self._final_path = full_path.replace("%SUB%", sub_path)
	self._file_path_to_cache.clear()

