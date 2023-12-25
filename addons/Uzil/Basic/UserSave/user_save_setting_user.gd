
## UserSave.Setting_User 用戶存檔 用戶設定
##
## 存取 用戶 本身相關存檔資料 設定
## 

# Variable ===================

## 要同步的 配置存檔
var profile

## 存檔設置 個體
var _inst

## 使用者名稱
var user_name := "unknown"

## 目錄路徑
var folder_path := ""

## 暫存 全路徑
var _full_path := ""

## 暫存 子路徑
var _sub_path := ""

# GDScript ===================

func _init (to_sync_profile_setting) :
	
	# 設置 要同步的 配置存檔
	self.profile = to_sync_profile_setting
	
	# 子路徑
	self._sub_path = "comm/%FILE%"

# Interface ==================

## 取得 全路徑
func get_full_path () -> String :
	return self._full_path

## 取得 子路徑
func get_sub_path () -> String :
	return self._sub_path

## 設置 存檔器實體
func set_inst (inst) :
	self._inst = inst
	if inst.setting != self :
		inst.set_setting(self)
	return self

# Public =====================

## 設置 目錄路徑
func set_folder (_folder_path) :
	
	self.folder_path = _folder_path
	
	# 更新 路徑
	self._update_full_path()
	
	return self

## 設置 用戶 名稱
func set_user (_user_name) :
	
	self.user_name = _user_name
	
	# 設置 配置存檔 用戶名稱
	self.profile.sync_from_user(_user_name)
	# 更新 路徑
	self._update_full_path()
	
	return self

# Private ====================

func _update_full_path () :
	# 設置 路徑
	self._full_path = self.folder_path.path_join(self.user_name.path_join("%SUB%"))
	# 更新 路徑
	self._inst._update_path()
	
