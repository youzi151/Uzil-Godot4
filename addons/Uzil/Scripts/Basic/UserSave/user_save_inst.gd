
## UserSave.Inst 用戶存檔 實體
##
## 以 設定檔 的 路徑, 存取各種存檔資料.
## 

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
	var file : FileAccess = FileAccess.open(self._get_file_path(path), FileAccess.READ)
	
	# 若 檔案不存在 則 返回 空
	if file == null :
		return null
	
	# 格式版本
	var format_version = file.get_var()
	
	# 檢查版本 並 警告 與 處理
	# TODO
#	print(format_version)
	
	# 內容
	var content = file.get_var()
	
	# 暫存內容
	self._file_path_to_cache[path] = content
	
	# 返回
	return content

## 讀取 值 (若可以則優先讀取快取)
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
	if content == null :
		return null
	
	# 依照 讀取到的內容 類型
	match typeof(content) :
		
		TYPE_DICTIONARY :
			
			var curr = content
			
			# 值 路徑
			var routes = route.split("/")
			for each in routes :
				
				# 若 下一個 路徑不存在 則 返回空
				if curr.has(each) == false :
					return null
				
				# 設 目前 為 下一個	
				curr = curr[each]

			return curr
			
		_ : 
			
			return content

## 寫入 整個
func write (path, content) :
	
	# 若 要寫入的內容 為 空 則 返回
	if content == null :
		return
	
	# 取得 完整檔案路徑
	var file_path = self._get_file_path(path)
	
	# 檢查 資料夾 是否存在
	var dir_path = file_path.get_base_dir()
	# 若 不存在 則 建立
	if not DirAccess.dir_exists_absolute(dir_path) :
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	# 開啟 檔案
	var file : FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	
	# 保存 格式版本
	file.store_var(G.v.Uzil.Basic.UserSave.FORMAT_VERSION)
	
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

## 寫入 值
func write_val (path, route, val) :
	# 若 值路徑 為 空 則 返回
	if route == null :
		print("[G.v.Uzil.Util.UserData.Base.write_val] route is null")
		return
		
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
		# 若 內容類型 不為 容器 (陣列或字串)
		var typ = typeof(content)
		if typ != TYPE_ARRAY and typ != TYPE_DICTIONARY :
			# 返回 (無法讀取值)
			print("[G.v.Uzil.Util.UserData.Base.write_val] file does not store dictionary, can not access member value")
			return
	
	# 當前
	var curr = content
	
	# 每個 值路徑 (除了最後一個要寫入的)
	var routes = route.split("/")
	var routes_size = routes.size()
	for idx in range(routes_size-1) :
		var each = routes[idx]
		
		# 若 值路徑 存在 則 取用
		if curr.has(each) :
			curr = curr[each]
		# 否則 新建立
		else :
			var new_dict = {}
			curr[each] = new_dict
			curr = new_dict
	
	# 以 指定值路徑 的 最後一個 路徑 為 鍵 設置 值
	var key = routes[routes_size-1]
	curr[key] = val
	
	# 寫入 內容
	self.write(path, content)
	

# Private ====================

## 更新 總路徑
func _update_path () :
	var sub_path = self.setting.get_sub_path()
	var full_path = self.setting.get_full_path()
#	print("full[%s], sub[%s]" % [full_path, sub_path])
	self._final_path = full_path.replace("%SUB%", sub_path)
	self._file_path_to_cache.clear()

## 取得 要使用的路徑
func _get_file_path (path) -> String :
	return self._final_path.replace("%FILE%", path)
