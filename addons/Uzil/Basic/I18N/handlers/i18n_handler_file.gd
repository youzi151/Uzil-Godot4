
## i18n handler file 在地化 處理器 檔案
##
## 讀取 檔案類榮 來 代換 關鍵字.[br]
## 可指定 檔案路徑 與 ini格式的區塊與鍵值 來取得 值.[br]
## 可插入 %LANG% 來在 取得 當前或備選語言 中 可用的 值.
##

# Variable ===================

## 正則式
var regex_pattern := "<@([^<>@]*)@>"

## 正則
var regex : RegEx = null

## 當 不存在時 替代
var replace_when_not_found = null

# GDScript ===================

func _init () :
	self.regex = RegEx.new()
	self.regex.compile(self.regex_pattern)

# Interface ==================

## 處理 翻譯
func handle (trans_task) :
	# 搜尋
	var matches = self.regex.search_all(trans_task.text)
	
	# 若 沒有找到 則 返回
	if matches.size() == 0 :
		return false
	
	# 是否有替換
	var is_trans := false
	
	# 已經替換過的鍵
	var replaced_keys := []
	
	# 語言
	var current_lang
	var current_fallback_langs : Array
	
	# 嘗試列表
	var to_try_langs : Array
	
	# 是否有 語言關鍵字 存在
	var is_key_lang_exist : bool = trans_task.text.contains("%LANG%")
	
	# 若有 語言關鍵字 存在
	if is_key_lang_exist :
		
		# 取得 語言相關
		current_lang = trans_task.inst.get_current_language()
		current_fallback_langs = trans_task.inst.get_current_fallback_languages()
		
		# 加入 嘗試列表
		to_try_langs = [current_lang]
		for each_fallback in current_fallback_langs :
			to_try_langs.push_back(each_fallback)
	
	# 每個 搜尋結果
	for each in matches :
		
		# 完整 關鍵字
		var full_key : String = each.get_string(1)
		# 若 該完整關鍵字 已經 替換過 則 忽略
		if replaced_keys.has(full_key) : break
		
		# 關鍵字解析 <@路徑|區塊:鍵@>
		
		# 路徑
		var path : String
		# 原始路徑
		var raw_path : String
		# 區塊
		var section = null
		# 鍵
		var key : String
		
		# 路徑 與 ini鍵
		var path_and_ini_key : PackedStringArray = full_key.split("|", true, 1)
		
		# 路徑
		path = path_and_ini_key[0]
		raw_path = path
		
		# ini鍵
		var ini_key = null
		
		# 若 有拆到2份 則 設 第2個 為ini鍵
		if path_and_ini_key.size() == 2 :
			ini_key = path_and_ini_key[1]
		
		# 若 ini鍵 存在
		if ini_key != null :
			
			# 拆分 區塊與鍵
			var section_and_key : PackedStringArray = ini_key.split(":", true, 1)
			# 若 不到 2個
			if section_and_key.size() < 2 :
				# 只 取用 鍵
				key = section_and_key[0]
			# 若 有2個
			else :
				# 前者 為 區塊
				section = section_and_key[0]
				# 後者 為 鍵
				key = section_and_key[1]
		
		# 嘗試 次數 (一般情形僅1次)
		var try_times = 1
		# 若 語言關鍵字 存在
		if is_key_lang_exist :
			# 嘗試次數 為 嘗試列表 總數
			try_times = to_try_langs.size()
		
		# 完整字串
		var full_str : String = each.get_string(0)
		# 要替換成的文字
		var replace = null
		
		# 逐次嘗試
		for idx in range(try_times) :
			
			# 若 語言關鍵字 不存在
			if is_key_lang_exist == false :
				# 若 該檔案 不存在 則 繼續下次嘗試
				if FileAccess.file_exists(path) == false : continue
			
			# 若 語言關鍵字 存在	
			else :
				
				# 取得 語言代號 並 替換 路徑
				var try_lang = to_try_langs[idx]
				var try_path = raw_path.replace("%LANG%", try_lang.code)
				
				# 若 該檔案 不存在 則 繼續下次嘗試
				if FileAccess.file_exists(try_path) == false : continue
				
				# 設置 本次路徑
				path = try_path
			
			# 若 ini鍵 不存在 則 視為 讀取整個檔案
			if ini_key == null : 
				var file : FileAccess = FileAccess.open(path, FileAccess.READ)
				replace = file.get_as_text()
			
			# 若 ini鍵 存在 則 讀取其中的值
			else :
				# 讀取 ini檔
				var file : ConfigFile = ConfigFile.new()
				var err = file.load(path)
				
				# 若 讀取不成功 則 繼續下次嘗試
				if err != OK : continue
					
				# 若 區塊 不存在 則 取預設區塊
				if section == null :
					section = ""
				
				# 若 該 區塊與鍵 不存在 則 繼續下次嘗試
#				print("path[%s] key[%s:%s] is exist? %s" % [path, section, key, file.has_section_key(section, key)])
				if file.has_section_key(section, key) == false : continue
				
				# 取得 值 設為 要替換成的文字
				replace = file.get_value(section, key)
			
			# 跳出嘗試
			break
			
		# 若 要替換成的文字 不存在
		if replace == null :
			# 若有 預設替換文字 則 使用
			if self.replace_when_not_found != null :
				replace = self.replace_when_not_found
			# 否則 不替換 並 繼續下個搜尋結果
			else :
				continue
		
		# 替換文字
		trans_task.text = (trans_task.text as String).replace(full_str, str(replace))
		
		# 紀錄 已替換過
		replaced_keys.push_back(full_key)
		is_trans = true
		
	return is_trans

# Public =====================

# Private ====================
