
## Uzupdater Config 設置
##
## Uzupdater更新器 可被更新的設置.
##

# Variable ===================

## 更新器:PCK 下載網址
const _UPDATER_PCK_DOWNLOAD_URL := "http://localhost:8000/pck"
## 更新器:PCK 存放位置
const _UPDATER_PCK_STORE_DIR_PATH := "pck"
## 更新器:PCK 更新列表
const _UPDATER_PCK_LIST := [
	"uzil"
]

var uzupdater = null

# GDScript ===================

func _init (_uzupdater) :
	self.uzupdater = _uzupdater

# Extends ====================

# Public =====================

# [更新器:PCK] ====

## 取得 更新器:PCK 下載網址
func get_updater_pck_download_url () :
	return self._UPDATER_PCK_DOWNLOAD_URL

## 取得 更新器:PCK 儲存位置
func get_updater_pck_dir_path () :
	return self.uzupdater.constant.get_local_store_root().path_join(self._UPDATER_PCK_STORE_DIR_PATH)

## 取得 更新器:PCK PCK列表
func get_updater_pck_list () :
#	print("uzupdater config in pck")
	return self._UPDATER_PCK_LIST

# Private ====================

