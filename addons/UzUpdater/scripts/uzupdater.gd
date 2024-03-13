extends Node

## Uzupdater 更新器
##
## 分為三個部分: 檢查, 裝載, 讀取 [br]
## 檢查: 確認有哪些資源需要更新, 並生產資源訂單. [br]
## 裝載: 依照資源訂單, 尋找或下載 對應 資源, 並 整理為最終讀取格式. [br]
## 讀取: 將 資源庫 中的資源讀取入遊戲中. [br]
## 

# Variable ===================

## 根路徑
const ROOT_PATH = "res://addons/Uzupdater"

## 腳本路徑
const PATH = ROOT_PATH + "/Scripts"

## 靜態腳本路徑
const STATIC_PATH = PATH + "/static"
## 可更新腳本路徑
const UPDATABLE_PATH = PATH + "/updatable"

## 任務
var Task

## 常數
var constant
## 設定
var config
## 非同步
var async
## 下載
var http

var _process_fn_list := []

# GDScript ===================

func _init () :
	
	if self.name == "" :
		self.name = "Uzupdater"
	
	# 任務
	self.Task = self.load_script(self.STATIC_PATH.path_join("util/uzupdater_task.gd"))
	
	# 非同步
	self.async = self.load_script(self.STATIC_PATH.path_join("util/uzupdater_async.gd")).new()
	# 下載
	self.http = self.load_script(self.STATIC_PATH.path_join("util/uzupdater_http.gd")).new(self)
	
	# 設定 (系統)
	self.constant = self.load_script(self.STATIC_PATH.path_join("uzupdater_constant.gd")).new(self)
	
	# 讀取 內容層
	self.reload_content()

func _process (_dt) :
	for each in self._process_fn_list :
		each.call(_dt)

# Extends ====================

# Public =====================

## 開始更新
func start_update (_on_done_fn = null) :
	
	# 任務
	var task = self.Task.new()
	task.uzupdater = self
	
	var total_updater = self.load_updater("uzupdater_updater_total.gd", false).new()
	total_updater.start_update(task, func():
		
		task.is_done = true
		
		if _on_done_fn != null :
			_on_done_fn.call()
	)
	
	return task

## 讀取 腳本
func load_script (path) :
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)

## 讀取 更新器
func load_updater (file_name, _is_updatable = true) :
	var dir : String = self.STATIC_PATH
	if _is_updatable : 
		dir = self.UPDATABLE_PATH
	return self.load_script(dir.path_join("updater").path_join(file_name))

## 重新讀取 內容層
func reload_content () :
#	print("reload_content")
	self.config = self.load_script(self.UPDATABLE_PATH.path_join("uzupdater_config.gd")).new(self)

func on_process (_on_process : Callable) :
	if self._process_fn_list.has(_on_process) : return _on_process
	self._process_fn_list.push_back(_on_process)
	return _on_process

func off_process (_on_process : Callable) :
	if not self._process_fn_list.has(_on_process) : return
	self._process_fn_list.erase(_on_process)

# Private ====================
