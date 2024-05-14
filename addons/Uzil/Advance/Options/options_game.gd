
## Options.Game 選項 遊戲
##
## 有關遊戲的選項, 如 語言, 背景執行 ...等
##

# Const ======================

## 在 設定檔案 中的 區塊名稱
const CFG_SECTION_NAME := "game"

const KEY_LANGUAGE := "language"
const KEY_IS_RUN_IN_BACKGROUND := "is_run_in_background"

# Variable ===================

## 是否在背景中執行
var _is_run_in_background := false

# GDScript ===================

# Extends ====================

# Public =====================

## 讀取 設定檔案
func load_config (file_path := "") :
	if file_path == "" :
		file_path = UREQ.acc(&"Uzil:Advance.Options").CONFIG_FILE_PATH
	
	var to_load_keys := [
		self.KEY_LANGUAGE,
		self.KEY_IS_RUN_IN_BACKGROUND,
	]
	
	var user_save = UREQ.acc(&"Uzil:user_save")
	var configs = user_save.config.reads(file_path, to_load_keys, {"section":self.CFG_SECTION_NAME})
	
	if configs.has(self.KEY_LANGUAGE) :
		self.set_language(configs[self.KEY_LANGUAGE], false)
	
	if configs.has(self.KEY_IS_RUN_IN_BACKGROUND) :
		self.set_run_in_background(configs[self.KEY_IS_RUN_IN_BACKGROUND], false)


## 取得 背景執行
func get_run_in_background () -> bool :
	return self._is_run_in_background

## 設置 背景執行
func set_run_in_background (is_run_in_background: bool, is_save_to_config := true) :
	
	# 設置 自己 的 是否在背景中執行
	self._is_run_in_background = is_run_in_background
	
	# 設置 背景計時
	var Times = UREQ.acc(&"Uzil:Core.Times")
	Times.is_timing_in_background_config = is_run_in_background
	
	if is_save_to_config :
		self._write_to_config(self.KEY_IS_RUN_IN_BACKGROUND, is_run_in_background)

## 取得 語言
func get_language () -> String :
	var i18n = UREQ.acc(&"Uzil:i18n")
	var lang = i18n.get_current_language()
	return lang.code

## 設置 邊框
func set_language (lang_code_or_name: String, is_save_to_config := true) :
	# 設置 語言
	var i18n = UREQ.acc(&"Uzil:i18n")
	i18n.change_language(lang_code_or_name)
	
	if is_save_to_config :
		self._write_to_config(self.KEY_LANGUAGE, lang_code_or_name)


# Private ====================

## 寫入 至 設定檔案
func _write_to_config (key, val) :
	var Options = UREQ.acc(&"Uzil:Advance.Options")
	var user_save = UREQ.acc(&"Uzil:user_save")
	user_save.config.write(Options.CONFIG_FILE_PATH, key, val, {"section":self.CFG_SECTION_NAME})

