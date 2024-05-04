
## UserSave.Setting.User 用戶存檔 設置 用戶
##
## 存取 用戶 本身相關存檔資料 設置
## 

# Variable ===================

## 路徑格式
var _path_format : String = "{FOLDER}/{USER}/comm/{FILE}"

## 路徑變數
var _path_var : Dictionary = {}

## 標幟
var flags : Dictionary = {}

## 模板路徑
var template_folders : Array = []

## 當 更新
var on_update = null

# GDScript ===================

func _init () :
	self.on_update = UREQ.acc("Uzil", "Evt").Inst.new()

# Interface ==================

## 取得 路徑格式
func get_path_format () -> String :
	return self._path_format

## 取得 路徑變數
func get_path_var () -> Dictionary :
	return self._path_var.duplicate()

## 添加模板目錄
func add_template_folders (folder_paths: Array) :
	for each in folder_paths :
		if not self.template_folders.has(each) :
			self.template_folders.push_back(each)
	return self

# Public =====================

## 設置 用戶 名稱
func set_user (_user_name) :
	self._path_var["USER"] = _user_name
	self._update_path()
	return self

## 設置 目錄路徑
func set_folder (_folder_path) :
	self._path_var["FOLDER"] = _folder_path
	self._update_path()
	return self

# Private ====================

func _update_path () :
	self.on_update.emit({
		"setting" : self,
		"path_preformat" : self._path_format.format(self._path_var),
	})
