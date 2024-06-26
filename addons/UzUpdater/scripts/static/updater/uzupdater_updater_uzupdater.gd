
## Uzupdater.Updater.Uzupdater 更新器 的 更新器
##
## 更新 更新器的 更新器.
##

# Variable ===================

# GDScript ===================

# Extends ====================

# Public =====================

## 開始
func start_update (task, on_done_fn: Callable) :
	print("updater_uzupdater start_update")
	
	# debug skip
#	on_done_fn.call(null)
#	return
	
	var uzupdater = task.uzupdater
	
	var FILE_PATH : String = uzupdater.constant.get_updater_uzupdater_file_path()
	
	# 是否需要更新
	var is_need_update := false
	
	# 若 檔案不存在
	if FileAccess.file_exists(FILE_PATH) == false :
		is_need_update = true
	# 若 版本需要更新
	elif self._is_need_update(task) :
		is_need_update = true
	
	var ref1 := {
		# 子進度
		"sub_progress" = null
	}
	
	uzupdater.async.waterfall([
		# check
		func(ctrlr):
			
			if not is_need_update :
				ctrlr.stop()
				return
			
			# 取得大小
			var sub_progress = task.request_sub_progress()
			sub_progress.cur = 0.0
			sub_progress.max = 1.0
			sub_progress.tags.push_back("file")
			sub_progress.tags.push_back("uzupdater")
			
			ref1.sub_progress = sub_progress
			
			# 若 新版版本資料 有 pck uzupdater的大小資料 則 覆寫
			if task.version_data_new.has("pck") :
				var pck_data_dict = task.version_data_new["pck"]
				if pck_data_dict.has("uzupdater") :
					var pck_data = pck_data_dict["uzupdater"]
					sub_progress.max = pck_data.size
				
			
			ctrlr.next()
			,
		
		# download
			
		func(ctrlr):
			
			var dir_path = ProjectSettings.globalize_path(FILE_PATH.get_base_dir())
			if not DirAccess.dir_exists_absolute(dir_path) :
				DirAccess.make_dir_recursive_absolute(dir_path)
			
			var ref2 := {}
			
			var DOWNLOAD_URL = uzupdater.constant.get_updater_uzupdater_download_url()
			var result = uzupdater.http.download(
				DOWNLOAD_URL,
				FILE_PATH,
				func(response):
					uzupdater.off_process(ref2.process_fn)
					
					if response.result != HTTPRequest.RESULT_SUCCESS :
						on_done_fn.call(uzupdater.http.result_string(response.result))
						return
						
					print("update uzupdater download done")
					ctrlr.next()
			)
			ref2.request = result.req
			
			ref2.process_fn = func(_dt):
				var downloaded = ref2.request.get_downloaded_bytes()
				ref1.sub_progress.cur = downloaded
				
				var total = ref2.request.get_body_size()
				if total != -1 : ref1.sub_progress.max = total

			uzupdater.on_process(ref2.process_fn)	
			,
	],
	func():
		# load
		var is_success = ProjectSettings.load_resource_pack(FILE_PATH)
		print(FILE_PATH)
		if not is_success :
			on_done_fn.call("load uzupdater pck failed")
			return
		
		# 重新讀取 內容層面
		uzupdater.reload_content()
		
		print("updater_uzupdater load pck : %s" % FILE_PATH)
		
		
		print("updater_uzupdater start_update done")
		on_done_fn.call(null)
	)
	

# Private ====================

## 是否需要更新
func _is_need_update (task) -> bool :
	# 若 當前版本 不存在 pck資料
	if not task.version_data_last.has("pck") :
		# 需要更新
		return true
	
	# 若 當前版本 的 pck資料 不存在 uzupdater資料
	var version_pck_dict_last = task.version_data_last["pck"]
	if not version_pck_dict_last.has("uzupdater") :
		# 需要更新
		return true
	
	# 若 新版版本 不存在 pck資料
	if not task.version_data_new.has("pck") :
		# 不需更新
		return false
	
	# 若 新版版本 的 pck資料 不存在 uzupdater資料
	var version_pck_dict_new = task.version_data_new["pck"]
	if not version_pck_dict_new.has("uzupdater") :
		# 不需更新
		return false
	
	# 若 當前 與 新版 的 uzupdater的檢查碼 不一致
	var version_uzupdater_last = version_pck_dict_last["uzupdater"]
	var version_uzupdater_new = version_pck_dict_new["uzupdater"]
	if version_uzupdater_new["check"] != version_uzupdater_last["check"] :
		# 需要更新
		return true
	
	return false
