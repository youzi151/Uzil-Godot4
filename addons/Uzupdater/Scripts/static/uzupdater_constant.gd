
## Uzupdater Constant 常數
##
## 定義 Uzupdater更新器 的 系統設置 如 路徑, 檔名
##

# Variable ===================

var uzupdater = null

## 本地儲存 根目錄
const _LOCAL_STORE_ROOT_WEB := "user://"
const _LOCAL_STORE_ROOT_MOBILE := "user://"
const _LOCAL_STORE_ROOT_PC := "./"
var _LOCAL_STORE_ROOT_EDITOR := ""

## 版本資訊 路徑
const _VERSION_DATA_FILE_PATH := "version.json"
## 版本資訊 下載網址
const _VERSION_DATA_DOWNLOAD_URL := "http://localhost:8000/version.json"

## 更新器:Uzupdater 下載網址
const _UPDATER_Uzupdater_URL := "http://localhost:8000/pck/uzupdater.pck"
## 更新器:Uzupdater 檔案存放路徑
const _UPDATER_Uzupdater_FILE_PATH := "pck/uzupdater.pck"

# GDScript ===================

func _init (_uzupdater) :
	self.uzupdater = _uzupdater
	self._LOCAL_STORE_ROOT_EDITOR = _uzupdater.ROOT_PATH.path_join("_test/download_local")

# Extends ====================

# Public =====================

## 取得 本地儲存 根目錄
func get_local_store_root () -> String :
	if OS.has_feature("web") :
		return self._LOCAL_STORE_ROOT_WEB
	elif OS.has_feature("mobile") :
		return self._LOCAL_STORE_ROOT_MOBILE
	elif OS.has_feature("pc") :
		if OS.has_feature("editor") :
			return self._LOCAL_STORE_ROOT_EDITOR
		else :
			return self._LOCAL_STORE_ROOT_PC
	else :
		return self._LOCAL_STORE_ROOT_PC

## 取得 版本資訊 檔案路徑
func get_version_data_file_path () -> String :
	return self.get_local_store_root().path_join(self._VERSION_DATA_FILE_PATH)

## 取得 版本資訊 下載網址
func get_version_data_download_url () -> String :
	return self._VERSION_DATA_DOWNLOAD_URL

# [更新器:Uzupdater] ====

## 取得 更新器:Uzupdater 下載網址
func get_updater_uzupdater_download_url () -> String :
	return self._UPDATER_Uzupdater_URL

## 取得 更新器:Uzupdater 儲存路徑
func get_updater_uzupdater_file_path () -> String :
	return self.get_local_store_root().path_join(self._UPDATER_Uzupdater_FILE_PATH)

# Private ====================

