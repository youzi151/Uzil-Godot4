
## UserSave.Configure 用戶存檔 設定
##
## 設定
##

# Variable ===================

var _write_buffered = null

## 設定存檔 目錄
var _folder_path : String

## 模板 目錄 (越後面越優先)
var template_paths : Array = []

## 是否從模板中複製到檔案
var is_copy_from_template_to_userdata : bool = true

# GDScript ===================

func _init (folder_path) :
	self._folder_path = folder_path

# Extends ====================

# Public =====================

## 緩衝 寫入
func write_buffer (file_path : String, section : String, key : String, val) :
	
	if self._write_buffered == null : 
		self._write_buffered = {}
	
	var file_buffered
	if self._write_buffered.has(file_path) :
		file_buffered = self._write_buffered[file_path]
	else :
		file_buffered = {}
		self._write_buffered[file_path] = file_buffered
	
	var section_buffered
	if file_buffered.has(section) :
		section_buffered = file_buffered[section]
	else :
		section_buffered = {}
		file_buffered[section] = section_buffered
	
	section_buffered[key] = val

## 緩衝寫入 到 檔案
func write_buffer_to () :
	
	if self._write_buffered == null : return
	
	for file_path in self._write_buffered.keys() :
		
		var full_path = self._folder_path.path_join(file_path)
		
		var file : ConfigFile = self._read_file(full_path)
		
		if file == null :
			var template_file = self._read_template(full_path)
			if template_file != null :
				file = template_file
			else :
				file = ConfigFile.new()
		
		# 檔案 的 每個 區塊
		var file_buffered = self._write_buffered[file_path]
		for section in self.file_buffered.keys() :
			
			# 區塊 的 每個 key
			var section_buffered = self.file_buffered[section]
			for key in section_buffered.keys() :
				
				var val = section_buffered[key]
				
				file.set_value(section, key, val)
			
		
		# 確保 路徑存在
		var dir_path = ProjectSettings.globalize_path(full_path.get_base_dir())
		if not DirAccess.dir_exists_absolute(dir_path) :
			DirAccess.make_dir_recursive_absolute(dir_path)
		
		file.save(full_path)
	
	self.write_buffered = null

## 寫入 值
func write_val (file_path : String, section : String, key : String, val) :
	self.write(file_path, section, {key:val})

## 寫入
func write (file_path : String, section : String, key_to_val : Dictionary) :
	# 完整路徑
	var full_path = self._folder_path.path_join(file_path)
	
	# 讀取 檔案
	var file : ConfigFile = self._read_file(full_path)
	
	# 若 該檔案不存在
	if file == null :
		var template_file = self._read_template(file_path)
		
		if template_file != null :
			file = template_file
		else :
			file = ConfigFile.new()
			
	for key in key_to_val.keys() :
		# 設置 指定內容
		file.set_value(section, key, key_to_val[key])
	
	# 確保 路徑存在
	var dir_path = ProjectSettings.globalize_path(full_path.get_base_dir())
	if not DirAccess.dir_exists_absolute(dir_path) :
		DirAccess.make_dir_recursive_absolute(dir_path)
		
	# 存檔
	file.save(full_path)
	

## 讀取 值
func read_val (file_path : String, section : String, key : String) :
	var results : Dictionary = self.read(file_path, section, [key])
	if not results.has(key) : return null
	return results[key]

## 讀取
func read (file_path : String, section : String = "", keys = null) :
	# 完整路徑
	var full_path = self._folder_path.path_join(file_path)
	# 讀取 檔案
	var file : ConfigFile = self._read_file(full_path)
	# 若 不存在 則 建立
	if file == null :
		file = ConfigFile.new()
	
	# 模板檔案
	var template_file : ConfigFile = self._read_template(file_path)
	
	# 總結果
	var results := {}
	
	# 是否 有 從 模板 轉讀 到 存檔
	var is_load_template_to_file = false
	
	# 若沒有指定key 則 取所有存在的key
	if keys == null :
		
		var exist_keys := {}
		
		if file.has_section(section) : 
			for key in file.get_section_keys(section) :
				exist_keys[key] = true
		
		# 若 模板檔 存在
		if template_file != null :
			var template_keys = template_file.get_section_keys(section)
			for key in template_keys :
				if not exist_keys.has(key) :
					exist_keys[key] = true
		
		keys = exist_keys.keys()
	
	# 每個 指定要找的key
	for key in keys :
		
		# 結果
		var result = null
		# 是否有該key的內容
		var has_value = false
		
		# 若 指定內容 存在 則 取得 為 結果
		if file.has_section_key(section, key) :
			result = file.get_value(section, key)
			has_value = true
		
		# 若 結果 不存在
		if not has_value :
			
			# 若 模板檔 存在
			if template_file != null :
				# 若 模板檔 存在 指定內容
#				G.print("%s %s" % [section, key])
				if template_file.has_section_key(section, key) :
					
					# 從 模板檔 取得 結果
					result = template_file.get_value(section, key)
					# 存 到檔案中
					file.set_value(section, key, result)
					
					has_value = true
					is_load_template_to_file = true
		
		# 若 結果存在 則 設置
		if has_value :
			results[key] = result
		
	
	if self.is_copy_from_template_to_userdata and is_load_template_to_file :
		# 確保 路徑存在
		var dir_path = ProjectSettings.globalize_path(full_path.get_base_dir())
		if not DirAccess.dir_exists_absolute(dir_path) :
			DirAccess.make_dir_recursive_absolute(dir_path)
		file.save(full_path)
	
	return results
	

# Private ====================

## 讀取 檔案
func _read_file (full_path : String) :
	
	var file := ConfigFile.new()
	# 若 檔案 存在
	if FileAccess.file_exists(full_path) :
		# 讀取
		var err = file.load(full_path)
		# 若 成功 則 返回
		if err == OK :
			return file
	
	#G.print("file[%s] exist ? : %s" % [full_path, FileAccess.file_exists(full_path)])
	
	return null

## 請求 模板
func _read_template (file_path) :
	# 讀取 模板檔
	#G.print(self.template_paths)
	for idx in range(self.template_paths.size()-1, -1, -1) :
		var each : String = self.template_paths[idx]
		var template_path = each.path_join(file_path)
		#G.print(file_path)
		var template_file : ConfigFile = self._read_file(template_path)
		#G.print(template_file)
		if template_file == null : continue
		return template_file
	return null
