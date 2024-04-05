
## Uzil.Basic.Res.Loader.BuiltIn 內建讀取器
##
## 提供 Godot內建資源讀取方式, 並進行相關快取.
## 也可使用非同步方式, 在子執行緒讀取資源.
##

## 讀取任務
class Task :
	## 當 讀取完成 信號
	signal on_loaded
	
	## 資源
	var res = null
	## 路徑
	var path : String
	## 指定類型
	var type_hint : String
	
	func _init (path : String, type_hint : String) :
		self.path = path
		self.type_hint = type_hint

# Variable ===================

## 資源
var Res = null

## 資源管理實體
var res_inst = null

## 完整路徑 對 資源資訊
var full_path_to_res_info := {}

## 待讀取的任務
var to_load_tasks := []

## 讀取中的任務
var loading_tasks := []

## 讀取任務數量的上限
var loading_task_max_count := 1

## 是否偵錯
var is_debug := false

# GDScript ===================

func _init (res_inst) :
	self.Res = UREQ.acc("Uzil", "Res")
	
	self.res_inst = res_inst
	
	# 以處理器數量 作為 讀取任務數量上限
	self.loading_task_max_count = OS.get_processor_count()

# Extends ====================

# Interface ==================

## 檢查 資源是否存在
func res_exist (full_path : String, options = null) :
	return self.full_path_to_res_info.has(full_path)

## 取得 資源
func res_get (full_path : String, options = null) :
	return self.full_path_to_res_info[full_path]

## 讀取 資源
func res_load (full_path : String, options = null) :
	
	var res_info = null
	
	# 資源類型
	var type_hint := ""
	
	# 特殊副檔名
	var file_ext := full_path.get_extension()
	# 文字檔
	match file_ext :
		"txt", "" :
			type_hint = "TextFile"
	
	# 選項
	if options != null :
		if options.has("type_hint") :
			type_hint = options["type_hint"]
	
	# 讀取
	var res = await self.load_by_path(full_path, type_hint)
	
	# 若 資源 存在
	if res != null :
		# 建立 資源資訊
		res_info = self.Res.Info.new(res)
		# 註冊 當釋放時 向 此讀取器 更新
		res_info.on_drop.push_back(func():
			self._update_res_info(res_info)
		)
		# 設置 完整路徑 (之後查找用)
		res_info.data.full_path = full_path
		
		if self.is_debug :
			G.print("[Res.Loader.BuiltIn] res_load : full_path[%s]" % [full_path])
			
		# 紀錄
		self.full_path_to_res_info[full_path] = res_info
	
	
	return res_info

## 釋放
func res_drop (res_info, holder) :
	# 若 指定 資源
	if res_info != null :
		# 若 指定 持有者 則 釋放 該持有者
		if holder != null :
			return res_info.drop(holder)
		# 若 無指定 持有者 則 釋放 所有持有者
		else :
			return res_info.drop_all()
	# 若 無指定 資源
	else :
		# 若 指定 持有者 則 對 所有資源 釋放 該持有者
		if holder != null :
			for each in self.full_path_to_res_info.values() :
				each.drop(holder)
		# 若 無指定 持有者 則 對 所有資源 釋放 所有持有者
		else :
			# 對 所有資源 釋放 該持有者
			for each in self.full_path_to_res_info.values() :
				each.drop_all()

# Public =====================

## 推進
func process (_dt) :
	
	# 剩餘 可讀取數量 (可讀取上限 - 當前讀取中)
	var left_loading_count := self.loading_task_max_count - self.loading_tasks.size()
	# 以 可讀取數量 或 剩餘要讀取任務數量 作為 處理數量
	var fill = min(left_loading_count, self.to_load_tasks.size())
	
	if self.is_debug and fill > 0 : G.print("process tasks ====")
	
	# 已結束的任務
	var done_tasks := []
	
	# 若 仍有 需處理數量
	while fill > 0 :
		# 取出 要讀取的任務
		var task = self.to_load_tasks.pop_back()
		
		if self.is_debug : G.print("start load : %s" % task.path)
		
		if not ResourceLoader.exists(task.path, task.type_hint) :
			# 設置 空資源
			task.res = null
			# 加入 已結束任務
			done_tasks.push_back(task)
		else :
			# 請求讀取
			ResourceLoader.load_threaded_request(task.path, task.type_hint, true, ResourceLoader.CACHE_MODE_IGNORE)
			
			# 加入 讀取中任務列表
			self.loading_tasks.push_back(task)
		
		# 減少 需處理數量
		fill -= 1
	
	# 若 讀取中任務 已歸零 則 返回
	if self.loading_tasks.size() == 0 : return
	
	# 每個 讀取中的任務
	for idx in range(self.loading_tasks.size()-1, -1, -1) :
		
		var each = self.loading_tasks[idx]
		
		# 依照 讀取狀態
		var state := ResourceLoader.load_threaded_get_status(each.path)
		match state :
			# 已讀取
			ResourceLoader.THREAD_LOAD_LOADED :
				# 將 任務 移出 讀取中
				var task = self.loading_tasks.pop_at(idx)
				# 取得並設置 資源
				task.res = ResourceLoader.load_threaded_get(task.path)
				if self.is_debug : G.print("loaded : %s" % task.path)
				# 加入 已結束任務
				done_tasks.push_back(task)
			# 非法讀取 或 讀取失敗
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE,  ResourceLoader.THREAD_LOAD_FAILED:
				# 將 任務 移出 讀取中
				var task = self.loading_tasks.pop_at(idx)
				# 設置 空資源
				task.res = null
				# 加入 已結束任務
				done_tasks.push_back(task)
	
	# 每個已結束任務
	for each in done_tasks :
		# 發送 讀取完畢 Signal
		each.on_loaded.emit()

## 讀取 資源 透過路徑
func load_by_path (full_path : String, type_hint : String = "") :
	# 試取得 檔案路徑
	var file_path = self.res_inst.get_file_path_if_is(full_path)
	# 資源
	var res = null
	
	if self.is_debug :
		G.print("[Res.Loader.BuiltIn] load_by_path : full_path[%s] type_hint[%s]" % [full_path, type_hint])
	
	# 若 檔案路徑 存在
	if file_path != null :
		full_path = file_path
	
	# 依照 資源類型
	match type_hint :
		# 文字檔
		"TextFile" :
			if FileAccess.file_exists(full_path) :
				var file := FileAccess.open(full_path, FileAccess.READ)
				res = {"text":file.get_as_text()}
		# 其他常規
		_ :
			var task = self.Task.new(full_path, type_hint)
			self.to_load_tasks.push_back(task)
			await task.on_loaded
			res = task.res
	
	if self.is_debug : 
		G.print("[Res.Loader.BuiltIn] load_by_path loaded res : %s" % res)
	
	return res

# Private ====================


## 更新 資源資訊
func _update_res_info (res_info) :
	# 若 非存活 則
	if not res_info.is_alive() :
		# 移除 註冊
		self.full_path_to_res_info.erase(res_info.data.full_path)
