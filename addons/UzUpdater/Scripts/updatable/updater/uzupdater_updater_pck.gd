
## Uzupdater.Updater.PCK PCK 的 更新器
##
## 檢查, 下載/移除, 讀取 各PCK.
##

# Variable ===================

const UPDATER_KEY := "pck"

## 是否 嚴謹讀取
var is_strict_load := true

# GDScript ===================

# Extends ====================

## 準備
func prepare_update (task) :
	
	print("==== updater_pck update prepare")
#	print("uzupdater updater pck in pck")
	
	var uzupdater = task.uzupdater
	var updater_pck_data = task.request_updater_data(self.UPDATER_KEY)
	
	var PCK_LIST = uzupdater.config.get_updater_pck_list()
	
	var PCK_STORE_DIR_PATH = ProjectSettings.globalize_path(uzupdater.config.get_updater_pck_dir_path())
	updater_pck_data["PCK_STORE_DIR_PATH"] = PCK_STORE_DIR_PATH
	
	# 要更新的列表
	var to_update_list : Array[String] = []
	# 要移除的列表
	var to_remove_list : Array[String] = []
			
	# 比對 版本資料 列出 需要更新的
	var version_diff_list : Array[String] = []
	
	# 當前版本 pck資料
	var version_pck_dict_last := {}
	if task.version_data_last.has("pck") :
		version_pck_dict_last = task.version_data_last["pck"]
	
	# 新版版本 pck資料
	var version_pck_dict_new := {}
	var version_pck_dict_new_keys := []
	if task.version_data_new.has("pck") : 
		version_pck_dict_new = task.version_data_new["pck"]
		version_pck_dict_new_keys = version_pck_dict_new.keys()
	
	# 每個 當前 pck資料
	for key in version_pck_dict_last.keys() :
		# 若 不在 新版版本 中 則 加入 要移除的列表
		if not version_pck_dict_new_keys.has(key) :
			to_remove_list.push_back(key)
	
	# 每個 新版 pck資料
	for key in version_pck_dict_new_keys :
		# 若 不在 當前版本 中 則 加入 版本不一致列表
		if not version_pck_dict_last.has(key) :
			version_diff_list.push_back(key)
			continue
		
		# 若 當前 與 新版 pck資料
		var pck_info_last = version_pck_dict_last[key]
		var pck_info_new = version_pck_dict_new[key]
		# 若 檢查碼 不一致 則 加入 版本不一致列表
		if pck_info_last["check"] != pck_info_new["check"] :
			version_diff_list.push_back(key)
			continue
	
	# 每個 遊戲定義的PCK
	for each in PCK_LIST :
		
		# 若 在 版本不一致列表 中 則 加入 要更新的列表
		if version_diff_list.has(each) :
			to_update_list.push_back(each)
			print("need update %s because new version avalible (or last version not exist)" % each)
			continue
		
		# 若 檔案 不存在 則 加入 要更新的列表
		var file_path = PCK_STORE_DIR_PATH.path_join(each+".pck")
		if not FileAccess.file_exists(file_path) :
			to_update_list.push_back(each)
			print("need update %s because file not exist" % each)
			continue
	
	# 依照 要更新的列表
	for each in to_update_list :
		# 申請 子進度 佔位
		var sub_progress_key = self._get_sub_progress_key(each)
		var sub_progress = task.request_sub_progress(sub_progress_key)
		var pck_info_new = version_pck_dict_new[each]
		sub_progress.max = pck_info_new["size"]
		sub_progress.tags.push_back("file")
		sub_progress.tags.push_back("main")
	
	# 紀錄 要更新/移除的列表
	updater_pck_data["to_update_list"] = to_update_list
	updater_pck_data["to_remove_list"] = to_remove_list
	

## 開始
func start_update (task, callback_fn : Callable) :
	print("==== updater_pck update start")
	
	var uzupdater = task.uzupdater
	
	var updater_pck_data : Dictionary = task.request_updater_data(self.UPDATER_KEY)
	var to_update_list : Array = updater_pck_data["to_update_list"]
	var to_remove_list : Array = updater_pck_data["to_remove_list"]
	
	var PCK_STORE_DIR_PATH : String = updater_pck_data["PCK_STORE_DIR_PATH"]
	var PCK_DOWNLOAD_URL : String = uzupdater.config.get_updater_pck_download_url()
	for each in to_remove_list :
		var store = PCK_STORE_DIR_PATH.path_join(each+".pck")
		if FileAccess.file_exists(store) :
			DirAccess.remove_absolute(store)
	
	# test
#	self.start_update_test(task, callback_fn)
#	return

	var ref = {}
	
	uzupdater.async.waterfall([
		# 檢查 階段 ====
			
		# 下載 階段 ====
		func (ctrlr) :
			
			# 確保 建立 目錄
			if not DirAccess.dir_exists_absolute(PCK_STORE_DIR_PATH) :
				DirAccess.make_dir_recursive_absolute(PCK_STORE_DIR_PATH)
				
			# 每個 要更新的PCK
			uzupdater.async.each_series(
				to_update_list,
				func (idx, each, ctrlr) :
					
					var url = PCK_DOWNLOAD_URL.path_join(each+".pck")
					var store = PCK_STORE_DIR_PATH.path_join(each+".pck")
					
					var ref2 = {}
					
					# 嘗試次數
					ref2.retry = 2
					
					var sub_progress_key = self._get_sub_progress_key(each)
					var sub_progress = task.request_sub_progress(sub_progress_key)
					
					task.current_sub_progress_key = sub_progress_key
					
					# 當 下載結束
					ref2.on_download_done = func (err) :
						# 若有錯誤
						if err != null :
							# 遞減嘗試次數
							ref2.retry -= 1
							# 若 還可繼續嘗試
							if ref2.retry > 0 :
								# 重新下載
								self.download_pck(task, sub_progress, url, store, ref2.on_download_done)
							else :
								# 停止更新
								self._end_update(task, callback_fn, "pck download fail : %s" % err)
								
							return
						
						ctrlr.next.call()
					
					# 開始下載
					self.download_pck(task, sub_progress, url, store, ref2.on_download_done)
					
					,
				func () :
					ctrlr.next.call()
			)
			,
			
		# 載入 階段 ====
		func (ctrlr) :
			
			# PCK存放目錄
			var pck_dst_dir : DirAccess = DirAccess.open(PCK_STORE_DIR_PATH)
			
			var PCK_LIST = uzupdater.config.get_updater_pck_list()
			
			# 其中的每個檔案
			for each in PCK_LIST :
				var full_path = PCK_STORE_DIR_PATH.path_join(each+".pck")
				print("updater_pck load %s" % full_path)
				# 載入 PCK
				var is_success = ProjectSettings.load_resource_pack(full_path)
				# 若 失敗 且 開啟 嚴格讀取
				if not is_success and self.is_strict_load :
					self._end_update(task, callback_fn, "load pck failed : %s" % each)
					return
			
			ctrlr.next.call()
	], func () :
		print("==== updater_pck update end")
		self._end_update(task, callback_fn, null)
	)

# Public =====================

func start_update_test (task, callback_fn : Callable) :
	
	# check
	
	# download
	var pck_src_path = task.uzupdater.PATH.path_join("_test/pck")
	var pck_src_dir : DirAccess = DirAccess.open(pck_src_path)
	var pck_dst_path = ProjectSettings.globalize_path("./pck")
	
	if not DirAccess.dir_exists_absolute(pck_dst_path) :
		DirAccess.make_dir_recursive_absolute(pck_dst_path)
	
	for file in pck_src_dir.get_files() :
		var file_abs_path = pck_src_path.path_join(file)
		DirAccess.copy_absolute(file_abs_path, pck_dst_path.path_join(file))
	
	# load
	var pck_dst_dir : DirAccess = DirAccess.open(pck_dst_path)
	var files = pck_dst_dir.get_files()
	for file in files :
		var full_path = pck_dst_path.path_join(file)
		ProjectSettings.load_resource_pack(full_path)
	
	callback_fn.call()

func download_pck (task, sub_progress, download_url, store_path, on_downloaded) :
	
	var uzupdater = task.uzupdater
	
	var ref = {}
	
	sub_progress.cur = 0
	
	# 下載
	var result = uzupdater.http.download(
		download_url, store_path,
		# 當 完成下載
		func (response) :
			# 移除 更新行為:進度更新
			if ref.has("update_progress_fn") :
				ref.update_progress_fn.call(0)
				uzupdater.off_process(ref.update_progress_fn)
			
			# 若 非成功
			if response.result != HTTPRequest.RESULT_SUCCESS :
				on_downloaded.call(uzupdater.http.result_string(response.result))
				return
				
			# 下個PCK
			on_downloaded.call(null)
	)
	
	if result.err != null :
		on_downloaded.call(result.err)
		return
	
	ref.request = result.req
	
	# 更新行為:進度更新
	# 依照 下載進度 設置 任務子進度
	ref.update_progress_fn = func (_dt) :
		
		var downloaded = ref.request.get_downloaded_bytes()
		sub_progress.cur = downloaded
		
		var total = ref.request.get_body_size()
		if total != -1 : sub_progress.max = total
	
	ref.update_progress_fn.call(0)
	
	# 註冊 更新行為:進度更新
	uzupdater.on_process(ref.update_progress_fn)

# Private ====================

func _get_sub_progress_key (pck_file_name) :
	return "updater_pck."+pck_file_name

func _end_update (task, callback_fn, err) :
	task.erase_updater_data(self.UPDATER_KEY)
	callback_fn.call(err)
