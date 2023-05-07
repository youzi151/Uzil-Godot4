
## Uzupdater.Updater.Total 更新器 全部
##
## 控制 其他更新器的 更新器.
##

# Variable ===================

# GDScript ===================

# Extends ====================

# Public =====================

## 開始
func start_update (task, on_done_fn : Callable) :
	print("==== updater_total update start")
	
	var uzupdater = task.uzupdater
	
	var sub_progress = task.request_sub_progress("updater_main")
	sub_progress.cur = 0.0
	sub_progress.max = 1.0
	
	uzupdater.async.waterfall([
		func (ctrlr) :
			# 處理 版本資訊
			self.handle_version_file(task, func (err) :
				
				# 若 錯誤
				if err != null :
					print("handle version file error : %s" % err)
					return
					
				ctrlr.next.call()
			)
			,
			
		func (ctrlr) :
			task.state = uzupdater.Task.UPDATE_STATE.Uzupdater

			# 更新器 的 更新器
			var updater_uzupdater = uzupdater.load_updater("uzupdater_updater_uzupdater.gd", false).new()
			# 更新 更新器
			updater_uzupdater.start_update(task, func(err):

				# 若 錯誤
				if err != null :
					print("update uzupdater error : %s" % err)
					return

				ctrlr.next.call()
			)
			,
			
		func (ctrlr) :
			
			task.state = uzupdater.Task.UPDATE_STATE.Main
			
			# 內容 的 更新器
			var updater_main = uzupdater.load_updater("uzupdater_updater_main.gd").new()
			# 更新內容
			updater_main.start_update(task, func(err):
				
				# 若 錯誤
				if err != null :
					print("update main error : %s" % err)
					return
					
				ctrlr.next.call()
			)
			, 
	],
		func () :
			
			task.state = uzupdater.Task.UPDATE_STATE.Done
			
			# 覆寫 版本資訊
			self.overwrite_version_data(task)
			
			sub_progress.cur = 1.0
			sub_progress.max = 1.0
			
			print("==== updater_total update end")
			on_done_fn.call()
	)
	

# Private ====================

## 處理 版本資訊
## 僅 設置 當前版本資訊 以及 新版版本資訊, 實際差異由各更新器自行比對
func handle_version_file (task, callback_fn) :
	
	var uzupdater = task.uzupdater
	
	# 當前 版本資訊
	var version_data_last := {}
	# 讀取 當前 版本資訊
	var VERSION_DATA_FILE_PATH = uzupdater.constant.get_version_data_file_path()
	if FileAccess.file_exists(VERSION_DATA_FILE_PATH) :
		var file = FileAccess.open(VERSION_DATA_FILE_PATH, FileAccess.READ)
		if file != null :
			version_data_last = JSON.parse_string(file.get_as_text())
			file.close()
	
	# 新版 版本資訊
	var version_data_new_str
	var version_data_new
	
	# 下載 新版 版本資訊
	var VERSION_DATA_DOWNLOAD_URL = uzupdater.constant.get_version_data_download_url()
	var result = uzupdater.http.request(
		VERSION_DATA_DOWNLOAD_URL,
		HTTPClient.METHOD_POST,
		"",
		func (response) :
			
			if response.result != HTTPRequest.RESULT_SUCCESS :
				callback_fn.call(uzupdater.http.result_string(response.result))
				return
			
			version_data_new_str = response.body.get_string_from_utf8()
			version_data_new = JSON.parse_string(version_data_new_str)
			
			# 若 取得失敗
			if version_data_new == null :
				var err = "parse version data fail."
				callback_fn.call(err)
				return
			
			# 儲存 至 任務 中
			task.version_data_last = version_data_last
			task.version_data_new = version_data_new
			task.version_data_new_str = version_data_new_str
			
			callback_fn.call(null)
	)
	
	if result.err != null :
		callback_fn.call("http error : %s" % result.err)

## 覆寫 版本資訊
func overwrite_version_data (task) :
	
	var uzupdater = task.uzupdater
	
	# 版本資訊 存放目錄
	var VERSION_DATA_FILE_PATH = uzupdater.constant.get_version_data_file_path()
	
	# 確保 存放目錄 存在
	var version_data_dir_path : String = ProjectSettings.globalize_path(VERSION_DATA_FILE_PATH.get_base_dir())
	if not DirAccess.dir_exists_absolute(version_data_dir_path) :
		print(error_string(DirAccess.make_dir_recursive_absolute(version_data_dir_path)))
		
	# 寫入 當前版本資訊 檔案
	var file = FileAccess.open(VERSION_DATA_FILE_PATH, FileAccess.WRITE)
	file.store_string(task.version_data_new_str)
	
	file.close()
