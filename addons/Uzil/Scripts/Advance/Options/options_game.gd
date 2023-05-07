extends Node

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass

# Extends ====================

# Public =====================

## 讀取 設定檔案
func load_config (file_path := "") :
	if file_path == "" :
		file_path = G.v.Uzil.Advance.Options.CONFIG_FILE_PATH
	
	var to_load_keys := [
		self.KEY_LANGUAGE, 
		self.KEY_IS_RUN_IN_BACKGROUND,
	]
	
	var configs = G.v.Uzil.user_save.config.read(file_path, self.CFG_SECTION_NAME, to_load_keys)
	
	if configs.has(self.KEY_LANGUAGE) :
		self.set_language(configs[self.KEY_LANGUAGE], false)
	
	if configs.has(self.KEY_IS_RUN_IN_BACKGROUND) :
		self.set_run_in_background(configs[self.KEY_IS_RUN_IN_BACKGROUND], false)


## 取得 背景執行
func get_run_in_background () -> bool :
	return self._is_run_in_background

## 設置 背景執行
func set_run_in_background (is_run_in_background : bool, is_save_to_config : bool = true) :
	
	# 設置 自己 的 是否在背景中執行
	self._is_run_in_background = is_run_in_background
	
	# 設置 背景計時
	G.v.Uzil.Core.Times.is_timing_in_background_config = is_run_in_background
	
	if is_save_to_config :
		self._write_to_config(self.KEY_IS_RUN_IN_BACKGROUND, is_run_in_background)

## 取得 語言
func get_language () -> String :
	var lang = G.v.Uzil.i18n.get_current_language()
	return lang.code

## 設置 邊框
func set_language (lang_code_or_name : String, is_save_to_config := true) :
	# 設置 語言
	G.v.Uzil.i18n.change_language(lang_code_or_name)
	
	if is_save_to_config :
		self._write_to_config(self.KEY_LANGUAGE, lang_code_or_name)


# Private ====================

## 寫入 至 設定檔案
func _write_to_config (key, val) :
	G.v.Uzil.user_save.config.write_val(G.v.Uzil.Advance.Options.CONFIG_FILE_PATH, self.CFG_SECTION_NAME, key, val)

