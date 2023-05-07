extends Node

## Options.Display 選項 顯示
##
## 有關顯示的選項, 如 視窗模式, 視窗大小, 無邊框...等. [br]
## 若要 起始設置正常運作, 則須將 專案設定 的 : [br]
## display/window/size/borderless 設為 true [br]
## display/window/size/viewport_width, viewport_height 設為 0 [br]
##

## 在 設定檔案 中的 區塊名稱
const CFG_SECTION_NAME := "display"

# Variable ===================

## 視窗數量
var window_count := 1

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
	
	var to_load_keys := []
	
	for idx in self.window_count :
		to_load_keys.push_back(self._get_key_window_width(idx))
		to_load_keys.push_back(self._get_key_window_height(idx))
		to_load_keys.push_back(self._get_key_window_borderless(idx))
		to_load_keys.push_back(self._get_key_window_fullscreen_mode(idx))
	
	var configs = G.v.Uzil.user_save.config.read(file_path, self.CFG_SECTION_NAME, to_load_keys)
	
	for idx in range(self.window_count) :
		self._load_config_window(idx, configs)


## 取得 解析度
func get_window_size (window_id := 0) -> Vector2i :
	return DisplayServer.window_get_size(window_id)

## 設置 解析度
func set_window_size (width : int, height : int, window_id : int = 0, is_save_to_config : bool = true) :
	
	var window_size = Vector2i(width, height)
	DisplayServer.window_set_size(window_size, window_id)
	
	var screen_size = DisplayServer.screen_get_size()
	var pos = screen_size / 2
	pos.x -= window_size.x / 2
	pos.y -= window_size.y / 2 
	DisplayServer.window_set_position(pos, window_id)
	
	if is_save_to_config :
		self._write_to_config(self._get_key_window_width(window_id), width)
		self._write_to_config(self._get_key_window_height(window_id), height)

## 取得 邊框
func get_borderless (window_id := 0) -> bool :
	return DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, window_id)

## 設置 邊框
func set_borderless (is_borderless : bool, window_id := 0, is_save_to_config := true) :
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, is_borderless, window_id)
#	print("set flag %s = %s" % [DisplayServer.WINDOW_FLAG_BORDERLESS, is_borderless])
	if is_save_to_config :
		self._write_to_config(self._get_key_window_borderless(window_id), is_borderless)

## 取得 視窗模式
func get_fullscreen_mode (window_id := 0) -> int :
	return DisplayServer.window_get_mode(window_id)

## 設置 視窗模式
func set_fullscreen_mode (fullscreen_mode, window_id := 0, is_save_to_config := true) :
	DisplayServer.window_set_mode(fullscreen_mode, window_id)
	if is_save_to_config :
		self._write_to_config(self._get_key_window_fullscreen_mode(window_id), fullscreen_mode)


# Private ====================

## 取得 視窗模式 的 關鍵字
func _get_key_window_fullscreen_mode (window_id : int) -> String :
	return self._get_key_with_suffix(window_id, "window%s_fullscreen_mode")

## 取得 視窗寬度 的 關鍵字	
func _get_key_window_width (window_id : int) -> String :
	return self._get_key_with_suffix(window_id, "window%s_width")

## 取得 視窗高度 的 關鍵字
func _get_key_window_height (window_id : int) -> String :
	return self._get_key_with_suffix(window_id, "window%s_height")

## 取得 視窗無邊框 的 關鍵字
func _get_key_window_borderless (window_id : int) -> String :
	return self._get_key_with_suffix(window_id, "window%s_borderless")

## 取得 指定視窗 的 關鍵字
func _get_key_with_suffix (window_id : int, key : String) -> String :
	var suffix = ""
	if window_id > 0 :
		suffix = "_"+str(window_id)
	return key % suffix

## 寫入 至 設定檔案
func _write_to_config (key, val) :
	G.v.Uzil.user_save.config.write_val(G.v.Uzil.Advance.Options.CONFIG_FILE_PATH, self.CFG_SECTION_NAME, key, val)
#	print(G.v.Uzil.Advance.Options.CONFIG_FILE_PATH)


## 讀取 設定 至 視窗
func _load_config_window (window_id : int, configs : Dictionary) :
	
#	print("load window config : %s" % window_id)
	
	# 視窗尺寸 (預設 全螢幕 不由模板檔決定)
	var window_size = DisplayServer.screen_get_size(0)
	
	var key_window_width = self._get_key_window_width(window_id)
	var has_window_width = configs.has(key_window_width)
	if has_window_width :
		window_size.x = configs[key_window_width]
		
	var key_window_height = self._get_key_window_height(window_id)
	var has_window_height = configs.has(key_window_height)
	if has_window_height :
		window_size.y = configs[key_window_height]
		
	if has_window_width or has_window_height :
		self.set_window_size(window_size.x, window_size.y, window_id, false)
	
	# 無邊框
	var key_borderless = self._get_key_window_borderless(window_id)
	if configs.has(key_borderless) :
#		print("set window[%s] key[%s] borderless to [%s]" % [window_id, key_borderless, configs[key_borderless]])
		self.set_borderless(configs[key_borderless], window_id, false)
	
	# 視窗模式
	# 最好最後再設置 否則 可能會因為 延遲 而把其他設置忽略/覆蓋掉
	var key_fullscreen_mode = self._get_key_window_fullscreen_mode(window_id)
	if configs.has(key_fullscreen_mode) :
		self.set_fullscreen_mode(configs[key_fullscreen_mode], window_id, false)

