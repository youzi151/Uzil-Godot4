extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 主視窗的子視圖
@export
var subviewport : SubViewport = null

## 子視窗 場景
@export
var window_2_tscn : PackedScene = null
## 子視窗
var window_2 : Window = null

# GDScript ===================


func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_options_display")
	
	var options = UREQ.acc(&"Uzil:options")
	options.display.load_config()
	
	# 綁定 視圖
	options.display.bind_viewport("subviewport", self.subviewport)
	options.display.load_config("", ["subviewport"], "")
	
	# 關閉 內嵌子視窗
	self.get_viewport().gui_embed_subwindows = false
	
	# 建立 新視窗
	self.window_2 = Window.new()
	self.window_2.add_child(self.window_2_tscn.instantiate())
	self.add_child(self.window_2)
	var screen_size := DisplayServer.screen_get_size()
	self.window_2.position = Vector2(screen_size.x/2, screen_size.y/2)
	self.window_2.size = Vector2(400, 300)
	self.window_2.visible = false
	self.window_2.close_requested.connect(func():self.window_2.hide())
	
	
	# 綁定 新視窗 與 其中視圖
	options.display.bind_window("window2", self.window_2)
	options.display.bind_viewport("window2_viewport", self.window_2.get_viewport())
	
	# 設 新視窗 視圖 與 主要視窗視圖不同
	# 尺寸
	options.display.set_window_size(self.window_2.size, "window2", false)
	# 無邊框
	var is_borderless : bool = options.display.get_window_borderless("")
	options.display.set_window_borderless(not is_borderless, "window2", false)
	# 全螢幕
	var fullscreen_mode : int = options.display.get_window_fullscreen_mode("")
	var fullscreen_mode_win2 : int = Window.MODE_WINDOWED
	if fullscreen_mode == Window.MODE_WINDOWED :
		fullscreen_mode_win2 = Window.MODE_FULLSCREEN
	options.display.set_window_fullscreen_mode(fullscreen_mode_win2, "window2", false)
	# 3D渲染比例
	var subviewport_3d_scale = options.display.get_viewport_scaling_3d_scale()
	var subviewport_3d_scale_win2 = clampf(1.0 - subviewport_3d_scale, 0.1, 1.0)
	options.display.set_viewport_scaling_3d_scale(subviewport_3d_scale_win2, "window2_viewport", false)
	
	# 應用
	options.display.apply()

func _exit_tree () :
	G.off_print("test_options_display")

# Extends ====================

# Public =====================

## 開關 子視窗
func test_sub_window_toggle () :
	if self.window_2.visible :
		self.window_2.hide()
	else :
		self.window_2.show()

## 切換 主視窗 尺寸
func test_window_size_toggle () :
	var options = UREQ.acc(&"Uzil:options")
	var size : Vector2i = options.display.get_window_size()
	var display_size : Vector2i = DisplayServer.screen_get_size()
	var new_size : Vector2i = display_size * 0.5
	if size.x == new_size.x :
		new_size = display_size * 0.75
	options.display.set_window_size(new_size)
	options.display.apply()

## 切換 主視窗/子視窗 3D渲染比例
func test_3d_scaling_toggle () :
	var options = UREQ.acc(&"Uzil:options")
	
	var scale : float = options.display.get_viewport_scaling_3d_scale()
	var last_scale : float = scale
	if scale != 1.0 :
		scale = 1.0
	else :
		scale = 0.1
		
	options.display.set_viewport_scaling_3d_scale(scale, "", true)
	options.display.set_viewport_scaling_3d_scale(scale, "subviewport", false)
	options.display.set_viewport_scaling_3d_scale(last_scale, "window2_viewport", false)
	
	scale = options.display.get_viewport_scaling_3d_scale()
	options.display.apply()
	
	G.print("scaling 3d scale : %s -> %s" % [last_scale, scale])
	
## 切換 主視窗/子視窗 無邊框
func test_borderless_toggle () :
	var options = UREQ.acc(&"Uzil:options")
	
	var is_borderless : bool = options.display.get_window_borderless()
	options.display.set_window_borderless(not is_borderless, "", true)
	options.display.set_window_borderless(is_borderless, "window2", false)
	options.display.apply()

## 切換 主視窗/子視窗 全螢幕
func test_fullscreen_toggle () :
	var options = UREQ.acc(&"Uzil:options")
	
	var fullscreen_mode : int = options.display.get_window_fullscreen_mode("")
	var fullscreen_mode_next : int = Window.MODE_WINDOWED
	if fullscreen_mode == Window.MODE_WINDOWED :
		fullscreen_mode_next = Window.MODE_FULLSCREEN
		
	options.display.set_window_fullscreen_mode(fullscreen_mode_next, "", true)
	options.display.set_window_fullscreen_mode(fullscreen_mode, "window2", false)
	options.display.apply()
