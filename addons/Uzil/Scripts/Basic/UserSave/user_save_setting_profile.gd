
## UserSave.Setting_Profile 用戶存檔 配置檔案設定
##
## 存取 用戶 的 各配置檔 相關存檔資料 設定
## 

# Variable ===================

## 存檔設置 個體
var _inst

## 目錄路徑
var folder_path := ""

## 暫存 全路徑
var _full_path := ""

## 暫存 子路徑
var _sub_path := ""

# GDScript ===================

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
	return self

## 設置 配置檔名稱
func set_profile (profile_name) :
	self._sub_path = profile_name
	self._inst._update_path()
	return self

## 設置 用戶 (由 UserSave_User 用戶存檔 設置)
func sync_from_user (user_name) :
	var full_path = self.folder_path.path_join(user_name.path_join("profile_%SUB%/%FILE%"))
	if self._full_path == full_path : return
	self._full_path = full_path
	self._inst._update_path()
	return self

# Private ====================

