
## UserSave.Setting.Profile 用戶存檔 設置 配置
##
## 存取 用戶 的 各配置檔 相關存檔資料 設置
## 

# Variable ===================

## 路徑格式
var _path_format : String = "{FOLDER}/{USER}/profile_{PROFILE}/{FILE}"

## 路徑變數
var _path_var : Dictionary = {}

## 標幟
var flags : Dictionary = {}

## 模板路徑
var template_folders : Array = []

## 當 更新
var on_update = null

# GDScript ===================

func _init (setting_user) :
	self.on_update = UREQ.acc(&"Uzil:Core.Evt").Inst.new()
	
	var user_path_var : Dictionary = setting_user.get_path_var()
	if "USER" in user_path_var :
		self._path_var["USER"] = user_path_var["USER"]
	setting_user.on_update.on(self._on_user_update)

# GDScript ===================

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

## 設置 配置檔名稱
func set_profile (profile_name: String) :
	self._path_var["PROFILE"] = profile_name
	self._update_path()
	return self

## 設置 目錄路徑
func set_folder (folder_path: String) :
	self._path_var["FOLDER"] = folder_path
	self._update_path()
	return self

# Private ====================

func _update_path () :
	self.on_update.emit({
		"setting" : self,
		"path_preformat" : self._path_format.format(self._path_var),
	})

func _on_user_update (_ctrlr) :
	var setting_user = _ctrlr.data["setting"]
	var user_path_var : Dictionary = setting_user.get_path_var()
	if "USER" in user_path_var :
		self._path_var["USER"] = user_path_var["USER"]
