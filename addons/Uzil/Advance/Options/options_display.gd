
## Options.Display 選項 顯示
##
## 有關顯示的選項, 如 視窗模式, 視窗大小, 無邊框...等. [br]
## 若要 起始設置正常運作, 則須將 專案設定 的 : [br]
## display/window/size/borderless 設為 true [br]
## display/window/size/viewport_width, viewport_height 設為 0 [br]
##

# Variable ===================

## 在 設定檔案 中的 區塊名稱
const CFG_SECTION_NAME := "display"

## 鍵:視窗
var _binded_window := {}
## 鍵:視圖
var _binded_viewport := {}

## 狀態
var _state_of_window := {}
var _state_of_viewport := {}

# GDScript ===================

func _init () :
	self._init_main_window()

# Extends ====================

# Public =====================

## 綁定視窗
func bind_window (key: String, window: Window) :
	if key == "" : return false
	self._binded_window[key] = window
	return true

## 取得 視窗
func get_window (key: String = "") -> Window :
	var res : Window = null
	if key == "" : self._init_main_window()
	if self._binded_window.has(key) :
		res = self._binded_window[key]
	else : return null
		
	if is_instance_valid(res) :
		return res
	else : return null

## 綁定視窗
func bind_viewport (key: String, viewport: Viewport) :
	if key == "" : return false
	self._binded_viewport[key] = viewport
	return true

## 取得 視窗
func get_viewport (key: String = "") -> Viewport :
	var res : Viewport = null
	if self._binded_viewport.has(key) :
		res = self._binded_viewport[key]
	else : return null
		
	if is_instance_valid(res) :
		return res
	else : return null

## 應用
func apply () :
	if OS.has_feature("web") : return
	for key in self._state_of_window :
		var window : Window = self.get_window(key)
		# 若 無法取得視窗
		if window == null : 
			# 若 為主視窗
			if key == "" :
				# 以 特別方式 應用到主視窗
				self._apply_to_main_window(self._state_of_window[key])
		# 一般情況
		else :
			self._apply_to_window(window, self._state_of_window[key])
		
	
	for key in self._state_of_viewport :
		var viewport : Viewport = self.get_viewport(key)
		if viewport == null : continue
		self._apply_to_viewport(viewport, self._state_of_viewport[key])

## 讀取 設定檔案
func load_config (file_path := "", target_display_keys: Array = [], save_key_tag = null) :
	if file_path == "" :
		file_path = UREQ.acc(&"Uzil:Advance.Options").CONFIG_FILE_PATH
	
	var windows := []
	var viewports := []
	
	# 若 無指定 則 填入所有已綁定
	if target_display_keys.size() == 0 :
		windows.append_array(self._binded_window.keys())
		viewports.append_array(self._binded_viewport.keys())
		if not self._binded_window.has("") :
			windows.push_back("")
	# 若 有指定 則 填入
	else :
		for each in target_display_keys :
			if self.get_window(each) != null :
				windows.push_back(each)
			if self.get_viewport(each) != null :
				viewports.push_back(each)
	
	# 預備要從設置檔中取得的key
	var to_load_keys := []
	
	# 若 有指定 設置檔中的display tag 則 從中取得
	if save_key_tag != null : 
		to_load_keys.push_back(self._get_key_window_size(save_key_tag))
		to_load_keys.push_back(self._get_key_window_borderless(save_key_tag))
		to_load_keys.push_back(self._get_key_window_fullscreen_mode(save_key_tag))
		to_load_keys.push_back(self._get_key_viewport_scaling_3d_scale(save_key_tag))
	# 若 無指定 則 以每個display的key作為 設置檔中的display tag
	else :
		for each in windows :
			to_load_keys.push_back(self._get_key_window_size(each))
			to_load_keys.push_back(self._get_key_window_borderless(each))
			to_load_keys.push_back(self._get_key_window_fullscreen_mode(each))
		for each in viewports :
			to_load_keys.push_back(self._get_key_viewport_scaling_3d_scale(each))
	
	# 取得 存檔配置 設定檔 (以要讀取的所有key)
	var user_save = UREQ.acc(&"Uzil:user_save")
	var configs = user_save.config.reads(file_path, to_load_keys, {"section":"display"})
	
	# 把 設定 讀取到各個display
	for each in windows :
		self._load_config_window(each, configs, save_key_tag)
	for each in viewports :
		self._load_config_viewport(each, configs, save_key_tag)

## 取得 解析度
func get_window_size (window_key := "", _is_from_state := true) -> Vector2i :
	if _is_from_state :
		var state = self._get_window_state(window_key, "size")
		if state != null : return state
	
	var window : Window = self.get_window(window_key)
	return window.get_size_with_decorations()

## 設置 解析度
func set_window_size (size: Vector2i, window_key: String = "", is_save_to_config := true) :
	self._set_state_window(window_key, "size", size)
	if is_save_to_config :
		self._write_to_config(self._get_key_window_size(window_key), size)

## 取得 邊框
func get_window_borderless (window_key := "", _is_from_state := true) -> bool :
	if _is_from_state :
		var state = self._get_window_state(window_key, "borderless")
		if state != null : return state
	
	
	var window : Window = self.get_window(window_key)
	return window.get_flag(Window.FLAG_BORDERLESS)

## 設置 邊框
func set_window_borderless (is_borderless: bool, window_key := "", is_save_to_config := true) :
	self._set_state_window(window_key, "borderless", is_borderless)
	if is_save_to_config :
		self._write_to_config(self._get_key_window_borderless(window_key), is_borderless)

## 取得 視窗模式
func get_window_fullscreen_mode (window_key := "", _is_from_state := true) -> int :
	if _is_from_state :
		var state = self._get_window_state(window_key, "fullscreen")
		if state != null : return state
	
	var window : Window = self.get_window(window_key)
	return window.mode

## 設置 視窗模式
func set_window_fullscreen_mode (fullscreen_mode: int, window_key := "", is_save_to_config := true) :
	self._set_state_window(window_key, "fullscreen", fullscreen_mode)
	if is_save_to_config :
		self._write_to_config(self._get_key_window_fullscreen_mode(window_key), fullscreen_mode)

   
## 取得 3D渲染比例
func get_viewport_scaling_3d_scale (viewport_key := "", _is_from_state := true) :
	if _is_from_state :
		var state = self._get_viewport_state(viewport_key, "scaling_3d_scale")
		if state != null : return state
	
	var viewport : Viewport = self.get_viewport(viewport_key)
	return viewport.scaling_3d_scale

## 設置 3D渲染比例
func set_viewport_scaling_3d_scale (scale: float, viewport_key := "", is_save_to_config := true) :
	self._set_state_viewport(viewport_key, "scaling_3d_scale", scale)
	if is_save_to_config :
		self._write_to_config(self._get_key_viewport_scaling_3d_scale(viewport_key), scale)

# Private ====================

## 讀取 設定 至 視窗
func _load_config_window (window_key: String, configs: Dictionary, save_key_tag = null) :
	#G.print("load window config : %s" % window_key)
	#G.print(configs)
	
	if save_key_tag == null :
		save_key_tag = window_key
	
	# 視窗尺寸 (預設 全螢幕 不由模板檔決定)
	var window_size = DisplayServer.screen_get_size(0)
	
	var key_window_size = self._get_key_window_size(save_key_tag)
	var has_window_size = configs.has(key_window_size)
	if has_window_size :
		window_size = configs[key_window_size]
		self.set_window_size(window_size, window_key, false)
	
	# 無邊框
	var key_borderless = self._get_key_window_borderless(save_key_tag)
	if configs.has(key_borderless) :
#		print("set window[%s] key[%s] borderless to [%s]" % [save_key_tag, key_borderless, configs[key_borderless]])
		self.set_window_borderless(configs[key_borderless], window_key, false)
	
	# 視窗模式
	# 最好最後再設置 否則 可能會因為 延遲 而把其他設置忽略/覆蓋掉
	var key_fullscreen_mode = self._get_key_window_fullscreen_mode(save_key_tag)
	if configs.has(key_fullscreen_mode) :
		self.set_window_fullscreen_mode(configs[key_fullscreen_mode], window_key, false)
		
	# 內容比例
	#var content_scale = self._get_key_window_content_scale(save_key_tag)
	#if configs.has(content_scale) :
		#self.set_window_content_scale(configs[content_scale], window_key, false)

## 讀取 設定 至 視圖
func _load_config_viewport (viewport_key: String, configs: Dictionary, save_key_tag = null) :
	if save_key_tag == null :
		save_key_tag = viewport_key
	
	# 3D渲染比例
	var scaling_3d_scale = self._get_key_viewport_scaling_3d_scale(save_key_tag)
	if configs.has(scaling_3d_scale) :
		self.set_viewport_scaling_3d_scale(configs[scaling_3d_scale], viewport_key, false)

## 取得 視窗 狀態
func _get_window_state (key: String, attr: String) :
	if not self._state_of_window.has(key) : return null
	var state : Dictionary = self._state_of_window[key]
	if not state.has(attr) : return null
	return state[attr]

## 取得 視圖 狀態
func _get_viewport_state (key: String, attr: String) :
	if not self._state_of_viewport.has(key) : return null
	var state : Dictionary = self._state_of_viewport[key]
	if not state.has(attr) : return null
	return state[attr]

## 設置 視窗 狀態
func _set_state_window (key: String, attr: String, val) :
	var state := {}
	if self._state_of_window.has(key) :
		state = self._state_of_window[key]
	else :
		self._state_of_window[key] = state
		
	if val == null :
		state.erase(attr)
	else :
		state[attr] = val
	

## 設置 視圖 狀態
func _set_state_viewport (key: String, attr: String, val) :
	var state := {}
	if self._state_of_viewport.has(key) :
		state = self._state_of_viewport[key]
	else :
		self._state_of_viewport[key] = state
		
	if val == null :
		state.erase(attr)
	else :
		state[attr] = val

## 應用 至 視窗
## 若需要在初始尚未有任何節點時, 就要設置視窗, 則需要透過另一種方式設置
## 但此方法可能會在 display/window/stretch/mode 非 disabled 時造成問題.
func _apply_to_main_window (state: Dictionary) :
	var window_id := 0
	var window_mode = DisplayServer.window_get_mode(window_id)
	if "fullscreen" in state :
		var cur = window_mode
		var nxt = state["fullscreen"]
		if cur != nxt :
			DisplayServer.window_set_mode(nxt, window_id)
			window_mode = nxt
	
	var nxt_borderless = null
	var cur_borderless : bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, window_id)
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN and cur_borderless == true :
		nxt_borderless = false
	else :
		if nxt_borderless == null and state.has("borderless") :
			var state_borderless = state["borderless"]
			if cur_borderless != state_borderless :
				nxt_borderless = state_borderless
	if nxt_borderless != null :
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, nxt_borderless, window_id)
	
	if window_mode == DisplayServer.WINDOW_MODE_WINDOWED and state.has("size") :
		var cur = DisplayServer.window_get_size(window_id)
		var nxt = state["size"]
		if cur != nxt :
			# 重設位置 置中
			var screen_size : Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(window_id))
			DisplayServer.window_set_position(Vector2(
				(screen_size.x - nxt.x) * 0.5,
				(screen_size.y - nxt.y) * 0.5,
			), window_id)
			# 設置尺寸
			DisplayServer.window_set_size(nxt, window_id)

## 應用 至 視窗
func _apply_to_window (window: Window, state: Dictionary) :
	
	if state.has("fullscreen") :
		var cur = window.mode
		var nxt = state["fullscreen"]
		if cur != nxt :
			window.mode = nxt
	
	var nxt_borderless = null
	var cur_borderless : bool = window.get_flag(Window.FLAG_BORDERLESS)
	if window.mode == Window.MODE_FULLSCREEN and cur_borderless == true :
		nxt_borderless = false
	else :
		if nxt_borderless == null and state.has("borderless") :
			var state_borderless = state["borderless"]
			if cur_borderless != state_borderless :
				nxt_borderless = state_borderless
	if nxt_borderless != null :
		window.set_flag(Window.FLAG_BORDERLESS, nxt_borderless)
	
	if window.mode == Window.MODE_WINDOWED and state.has("size") :
		var cur = window.size
		var nxt = state["size"]
		if cur != nxt :
			var screen_size : Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen(0))
			var pos : Vector2 = Vector2(
				(screen_size.x - nxt.x) * 0.5,
				(screen_size.y - nxt.y) * 0.5,
			)
			window.position = pos
			window.size = nxt
		

## 應用 至 視圖
func _apply_to_viewport (viewport: Viewport, state: Dictionary) :
	
	if state.has("scaling_3d_scale") :
		var cur = viewport.scaling_3d_scale
		var nxt = state["scaling_3d_scale"]
		if cur != nxt :
			viewport.scaling_3d_scale = nxt

## 取得 視窗 狀態快照
func _get_snapshot_window (window: Window) :
	return {
		"size" : window.size,
		"fullscreen" : window.mode,
		"borderless" : window.get_flag(Window.FLAG_BORDERLESS),
	}

## 取得 視圖 狀態快照
func _get_snapshot_viewport (viewport: Viewport) :
	return {
		"scaling_3d_scale" : viewport.scaling_3d_scale,
	}

## 取得 視窗模式 的 關鍵字
func _get_key_window_fullscreen_mode (window_key: String) -> String :
	return self._get_key_with_suffix(window_key, "window%s_fullscreen_mode")

## 取得 視窗大小 的 關鍵字	
func _get_key_window_size (window_key: String) -> String :
	return self._get_key_with_suffix(window_key, "window%s_size")

## 取得 視窗無邊框 的 關鍵字
func _get_key_window_borderless (window_key: String) -> String :
	return self._get_key_with_suffix(window_key, "window%s_borderless")

## 取得 視窗內容比例 的 關鍵字
#func _get_key_window_content_scale (window_key: String) -> String :
	#return self._get_key_with_suffix(window_key, "window%s_content_scale")

## 取得 視窗內容比例 的 關鍵字
func _get_key_viewport_scaling_3d_scale (window_key: String) -> String :
	return self._get_key_with_suffix(window_key, "viewport%s_scaling_3d_scale")

## 取得 指定視窗 的 關鍵字
func _get_key_with_suffix (window_key: String, key: String) -> String :
	var suffix = ""
	if not window_key.is_empty() : 
		suffix = "_%s" % window_key
	return key % suffix

## 寫入 至 設定檔案
func _write_to_config (key, val) :
	var Options = UREQ.acc(&"Uzil:Advance.Options")
	var user_save = UREQ.acc(&"Uzil:user_save")
	user_save.config.write(Options.CONFIG_FILE_PATH, key, val, {"section":self.CFG_SECTION_NAME})
#	print(Options.CONFIG_FILE_PATH)

func _init_main_window () :
	if self._binded_window.has("") : return
	if not "main_window" in G.v : return
	var main_window : Window = G.v["main_window"]
	self._binded_window[""] = main_window
	self._binded_viewport[""] = main_window.get_viewport()
