## UzUpdater更新器
## 
## 遊戲更新系統 可自動檢查、下載和安裝遊戲更新。
## 主要特點:
## - 支援分階段更新:先更新更新器本身，再更新遊戲內容
## - 支援多種資源類型:PCK檔案、腳本檔案等
## - 提供進度追蹤和錯誤處理
## - 支援版本控制和增量更新
##
## 目錄結構:
## - static: 靜態, 不可更新的部分.
##   - updater: 更新器
##     - uzupdater_updater_total.gd: 總更新器, 負責整合 版本資訊, 更新器的更新器, 內容的更新器.
##     - uzupdater_updater_uzupdater.gd: 更新器 的 更新器.
##   - util: 工具, 工具函數.
##   - constant: 常數, 常數函數.
##
## - updatable: 可更新, 可通過更新系統替換的部分.
##   - updater: 更新器
##     - uzupdater_updater_main.gd: 內容 的 更新器.
##     - uzupdater_updater_pck.gd: PCK 的 更新器.
##   - config: 設置, 設置函數.
##
## 更新流程:
## - 建立 更新器 uzupdater.gd
## - uzupdater.start_update()
## - uzupdater內會 建立 總更新器 updater_total 並 開始處理:
##   - 處理 version.json 版本資訊.
##   - 使用 updater_uzupdater 更新器的更新器. 來更新 更新器.
##   - 後續流程所用腳本, 若有被打包在 "pck/uzupdater.pck" 中 則 可被 updater_uzupdater 更新.
##   - 使用 updater_main 更新內容:
##     - 使用 updater_pck PCK的更新器. 來更新 PCK.
##       - 依照 version.json中的pck資訊, 對各pck進行下載/移除/加載.
## - 完成更新.
## 

@tool
extends EditorPlugin

func _enter_tree () :
	pass

func _exit_tree () :
	pass
