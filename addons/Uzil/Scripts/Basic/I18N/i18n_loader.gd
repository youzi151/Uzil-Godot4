
## i18n loader 讀取器
##
## 讀取 語言資料 與 字典 相關 檔案.
##

# Variable ===================

# GDScript ===================

# Extends ====================

# Public =====================

# Private ====================

# Static =====================

## 讀取 語言目錄 總目錄
func load_langs (dir_path) :
	
	# 所有 語言目錄 的 所在目錄
	var dir := DirAccess.open(dir_path)
	if dir == null : return null
	
	# 所有 語言目錄
	var lang_dirs := dir.get_directories()
	
	# 總覽表
	var code_to_lang := {}
	
	# 每個 語言目錄
	for each in lang_dirs :
		# 讀取 該語言
		var lang = self.load_lang(dir_path.path_join(each))
		if lang == null : continue
		# 紀錄
		code_to_lang[lang.code] = lang
	
	# 返回 總覽
	return code_to_lang

## 讀取 語言 目錄
func load_lang (dir_path) :
	
	# 語言目錄
	var dir := DirAccess.open(dir_path)
	if dir == null : return null
	
	var I18N = UREQ.access_g("Uzil", "I18N")
	
	# 描述檔(必備基本資料) 的 路徑
	var meta_file_path : String = dir_path.path_join(I18N.LANG_META_FILE_NAME)
	if FileAccess.file_exists(meta_file_path) == false : return null
	
	# 描述檔
	var meta_file := ConfigFile.new()
	var err := meta_file.load(meta_file_path)
#	print("load[%s][%s]" % [(err == OK), meta_file_path])
	if err != OK : return null
	
	# 建立 語言資料
	var lang = I18N.Lang.new()
	lang.dir_path = dir_path
	
	var section := ""
	
	var lang_keys = meta_file.get_section_keys(section)
	
	# 代碼 (必備)
	if lang_keys.has("code") == false : return null
	lang.code = meta_file.get_value(section, "code")
	
	# 別名
	if lang_keys.has("alias") :
		lang.alias = meta_file.get_value(section, "alias")
	
	# 備選語言(代碼)
	if lang_keys.has("fallback_langs") : 
		lang.fallback_langs = meta_file.get_value(section, "fallback_langs")
	
	return lang

## 卸載 所有字典 從 語言
func unload_dicts (lang) :
	lang.key_to_word.clear()

## 讀取 所有字典 至 語言
func load_dicts (lang) :
	
	# 語言 目錄
	var dir := DirAccess.open(lang.dir_path)
	if dir == null : return null
	
	var I18N = UREQ.access_g("Uzil", "I18N")
	
	# 每個 檔案
	var file_names := dir.get_files()
	for each_name in file_names :
		# 除了 _meta.ini
		if each_name == I18N.LANG_META_FILE_NAME : continue
		
		# 匯入 字典
		var each_path = lang.dir_path.path_join(each_name)
		self.load_dict(lang, each_path)
	

## 讀取 字典 至 語言
func load_dict (lang, path) :
	# 若 該檔案不存在 則 返回
	if FileAccess.file_exists(path) == false : return null
	
	# 檔案
	var file := ConfigFile.new()
	var err := file.load(path)
	if err != OK : return null
	
	# 讀取 空區塊 的 所有 鍵:詞
	var dict_section := ""
	if file.has_section(dict_section) :
		var dict_keys = file.get_section_keys(dict_section)
		for key in dict_keys :
			var word = file.get_value(dict_section, key)
			lang.key_to_word[key] = word
#			print("[i18n_loader] add %s:%s to %s" % [key, word, lang.code])
			
		
	return lang
	
