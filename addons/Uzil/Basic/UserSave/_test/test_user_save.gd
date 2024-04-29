extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 使用者名稱 輸入
@export var user_edit : LineEdit
## 配置名稱 輸入
@export var profile_edit : LineEdit
## 是否存至配置 勾選
@export var save_to_profile_checkbox : CheckBox
## 是否存至配置
var _is_save_to_profile : bool = false

## 檔案名稱 輸入
@export var file_name_edit : LineEdit
## 檔案 完整路徑 文字
@export var file_full_path_label : RichTextLabel

## 存檔屬性名稱 輸入
@export var save_route_edit : LineEdit
## 存檔屬性內容 輸入
@export var save_val_edit : LineEdit

var current_file_name : String = ""

# GDScript ====================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_user_save")
	
	var user_save = UREQ.acc("Uzil", "user_save")
	
	# 當 使用者 輸入
	self.user_edit.text_changed.connect(func(new_text : String):
		if new_text == "" or new_text == null :
			new_text = "Test"
			self.user_edit.text = new_text
		user_save.user.set_user(new_text)
	)
	user_save.user.setting.set_user(self.user_edit.text)
	
	# 當 配置 輸入
	self.profile_edit.text_changed.connect(func(new_text : String):
		if new_text == "" or new_text == null :
			new_text = "default"
			self.profile_edit.text = new_text
		user_save.profile.set_profile(new_text)
	)
	user_save.profile.setting.set_profile(self.profile_edit.text)
	
	# 當 是否使用 配置 勾選 (不使用 則 會存在 使用者)
	self.save_to_profile_checkbox.pressed.connect(func():
		self._is_save_to_profile = self.save_to_profile_checkbox.button_pressed
		self._update_file_path_label()
	)
	self._is_save_to_profile = self.save_to_profile_checkbox.button_pressed
	
	# 當 檔名 輸入
	self.file_name_edit.text_changed.connect(func(new_text : String):
		if new_text == "" or new_text == null :
			new_text = "test.sav"
			self.file_name_edit.text = new_text
			
		self.current_file_name = new_text
		self._update_file_path_label()
	)
	self.current_file_name = self.file_name_edit.text
	self._update_file_path_label()
	



func _exit_tree () :
	G.off_print("test_user_save")

# Extends ====================

# Public =====================

func test_save () :
	var user_save = UREQ.acc("Uzil", "user_save")
	var route = self.save_route_edit.text
	
	var val = self.save_val_edit.text
	if val == "" : 
		val = null
	else :
		var try_json = JSON.parse_string(val)
		if try_json != null : 
			val = try_json
	
	# 依照 是否存在配置 選擇 存檔實例
	var inst
	if self._is_save_to_profile :
		inst = user_save.profile
	else :
		inst = user_save.user
	
	# 若 沒有值路徑 則 視為 整個檔案
	if route == "" :
		inst.write(self.current_file_name, "", val)
	else :
		inst.write(self.current_file_name, route, val)
	
	G.print("saved")

func test_load () :
	var user_save = UREQ.acc("Uzil", "user_save")
	var route = self.save_route_edit.text
	var val = null
	
	# 依照 是否存在配置 選擇 存檔實例
	var inst
	if self._is_save_to_profile :
		inst = user_save.profile
	else :
		inst = user_save.user
	
	# 若 沒有值路徑 則 視為 整個檔案
	if route == "" :
		val = inst.read(self.current_file_name)
	else :
		val = inst.read(self.current_file_name, route)
	
	# 若 值存在 則 設置到 值輸入
	if val != null :
		self.save_val_edit.text = str(val)
	else :
		self.save_val_edit.text = ""
	
	# 依照 值路徑 或 整個檔案 顯示對應偵錯 
	if route == "" :
		G.print("file[%s] loaded:" % self.current_file_name)
	else :
		G.print("route[%s] loaded:" % route)
	G.print(val)

func test_simple () :
	
	var UserSave = UREQ.acc("Uzil", "Basic.UserSave")
	var user_save = UREQ.acc("Uzil", "user_save")
	
	G.print("os user path : %s" % OS.get_user_data_dir())
	G.print("uzil usersave path : %s" % UserSave.get_save_folder_root())
	
	G.print("== write/read full string")
	user_save.user.write("user_fullstr.sav", "", "fff")
	G.print(user_save.user.read("user_fullstr.sav"))
	
	G.print("== write/read full dict")
	user_save.user.writes("user_fulldict.sav", {
		"test1":{
			"test2":456
		},
		"test":{
			"num": 123,
			"test_rm": 123,
		}
	})
	G.print(user_save.user.read("user_fulldict.sav"))
	
	G.print("== write/read dict val")
	user_save.user.write("user_fulldict.sav", "test1/test2", 789)
	G.print(user_save.user.read("user_fulldict.sav", "test1/test2"))
	
	
	G.print("== read full dict")
	G.print(user_save.user.read("user_fulldict.sav"))
	
	G.print("== write/read dict val overwrite val by route")
	user_save.user.write("user_fulldict.sav", "test1/test2/test3", 789)
	G.print(user_save.user.read("user_fulldict.sav", "test1/test2/test3"))
	
	G.print("== erase/read dict val")
	user_save.user.write("user_fulldict.sav", "test/test_rm", null)
	G.print(user_save.user.read("user_fulldict.sav", "test"))
	
	G.print("== read full dict")
	G.print(user_save.user.read("user_fulldict.sav"))
	
	
	user_save.user.setting.set_user("steam_9527")
	
	G.print("== write/read user")
	user_save.user.write("user_steam_fullstr.sav", "", "strrrrr")
	G.print(user_save.user.read("user_steam_fullstr.sav"))
	
	G.print("== write/read profile")
	user_save.profile.setting.set_profile("John")
	user_save.profile.write("profile_fullstr.sav", "", "pppppppp")
	G.print(user_save.profile.read("profile_fullstr.sav"))
	

func _update_file_path_label () :
	var user_save = UREQ.acc("Uzil", "user_save")
	var path_var : Dictionary = {"FILE":self.current_file_name}
	if self._is_save_to_profile :
		path_var.merge(user_save.profile.setting.get_path_var(), false)
		G.print(user_save.profile.setting.get_path_format())
		G.print(path_var)
		self.file_full_path_label.text = user_save.profile.setting.get_path_format().format(path_var)
	else :
		path_var.merge(user_save.user.setting.get_path_var(), false)
		G.print(user_save.user.setting.get_path_format())
		G.print(path_var)
		self.file_full_path_label.text = user_save.user.setting.get_path_format().format(path_var)
