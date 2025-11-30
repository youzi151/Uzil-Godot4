
## TaskQueue.Inst行動佇列 實例
## 
## 
## 

class FlagInfo :
	## 計數: 除了本身flag以外的操作都計算在這
	var count := 0
	## 使用者: add_flag, sub_flag 若 有指定使用者 則 紀錄於此
	var users := {}
	## 任務: 任務本身的flag會記錄於此
	var tasks := {}
	func to_string () :
		return "[%s]-%s" % [count, tasks]

# Variable ===================

var TaskQueue

## 佇列
var _tasks := []

## 當前標記
var _current_flags := {}

## 是否處理中
var _is_processing := false
## 處理中 任務是否有變
var _is_processing_tasks_changed := false
## 待加入的
var _to_add_tasks := []
## 待移除的
var _to_del_tasks := {}

# GDScript ===================

func _init () :
	self.TaskQueue = UREQ.acc(&"Uzil:TaskQueue")

# Extends ====================

# Interface ==================

# Public =====================

## 加入 任務
func add_task (task: RefCounted) :
	# 若 處理中 則 加入 待加入列表
	if self._is_processing :
		if self._to_add_tasks.has(task) : return
		self._to_add_tasks.push_back(task)
		self._is_processing_tasks_changed = true
	# 否則 直接加入 佇列
	else :
		if self._tasks.has(task) : return
		self._tasks.push_back(task)
	
	# 設置 預先標記
	for each in task.reserve_flags :
		var flag_info : FlagInfo = self._get_flag_info(each)
		flag_info.count += 1
	
	# 刷新 當前標記
	self._refresh_flags()

## 移除 任務
func del_task (task: RefCounted) :
	# 若 處理中 則
	if self._is_processing :
		# 試著從 待加入列表 移除
		if self._to_add_tasks.has(task) : self._to_add_tasks.erase(task)
		# 若 不在 佇列 中 則 返回
		if not self._tasks.has(task) : return
		# 若 已在 待移除列表 中 則 返回
		if self._to_del_tasks.has(task) : return
		# 加入 待移除列表
		self._to_del_tasks[task] = true
		# 設置 處理中 任務有變更
		self._is_processing_tasks_changed = true
	else :
		# 若 不在 佇列 中 則 返回
		if not self._tasks.has(task) : return
		# 移除 佇列
		self._tasks.erase(task)
	
	# 刷新 當前標記
	self._refresh_flags()

## 排序
func sort () :
	self._tasks.sort_custom(func(a, b):
		return a.sort < b.sort
	)

## 添加標記
func add_flag (flag: String, _user = null) :
	var flag_info : FlagInfo = self._get_flag_info(flag)
	# 若 有指定使用者 則 紀錄於 使用者列表
	if _user != null :
		flag_info.users[_user] = true
	# 否則 計數增加
	else :
		flag_info.count += 1

## 移除標記
func sub_flag (flag: String, _user = null) :
	# 若 不在 當前標記 中 則 返回
	if not self._current_flags.has(flag) : return
	# 取得 標記資訊
	var flag_info : FlagInfo = self._get_flag_info(flag)
	# 若 有指定使用者 則 從使用者列表 移除
	if _user != null :
		flag_info.users.erase(_user)
	# 否則 計數減少 (直到0)
	else :
		if flag_info.count > 0 :
			flag_info.count -= 1

## 清除
func clear () :
	self._current_flags.clear()
	self._tasks.clear()

## 取得 當前標記 字串
func get_current_flags_str () :
	var msg := ""
	for flag in self._current_flags :
		msg += "%s : %s" % [flag, self._current_flags[flag]]
	return msg

## 推進
func process () :
	# 設置 處理中
	self._is_processing = true
	
	# 若 有 待移除的 任務 則 移除
	if not self._to_del_tasks.is_empty() :
		self._tasks = self._tasks.filter(func(e): return not self._to_del_tasks.has(e))
		self._to_del_tasks = {}
	
	# 若 有 待加入的 任務 則 加入 佇列
	if not self._to_add_tasks.is_empty() :
		self._tasks.append_array(self._to_add_tasks)
		self._to_add_tasks = []
	
	var empty_dict := {}
	
	# 標記 對應的 batch info
	var flag_to_batch_info := {}
	# 任務 對應的 batch infos
	var task_to_batch_infos := {}
	
	# 蒐集 batch相關資訊
	for task in self._tasks :
		var has_batch : bool = not task.batch_flags.is_empty()
		if not has_batch : continue
		
		# 該任務 對應的 batch infos
		var task_batch_infos := []
		
		# 每個 batch flag
		for flag in task.batch_flags :
			var batch_info := empty_dict
			# 取得 或 建立 batch info
			if flag_to_batch_info.has(flag) :
				batch_info = flag_to_batch_info[flag]
			else :
				empty_dict = {}
				batch_info["tasks"] = {}
				flag_to_batch_info[flag] = batch_info
			# 加入 該batch info 的 任務
			batch_info["tasks"][task] = true
			
			# 加入 該任務對應的batchinfos
			task_batch_infos.push_back(batch_info)
		
		task_to_batch_infos[task] = task_batch_infos
		
	
	# 開始的任務
	var started_tasks := {}
	# 通過的 batch 任務
	var passed_batch_tasks := {}
	# 不通過的 任務
	var not_pass_tasks := {}
	# 忽略的 batch
	var skip_batchs := {}
	# 剩餘的 batch 任務
	var extra_batch_tasks := []
	
	# 每個任務
	for task in self._tasks :
		# 若中途有變更任務 則 跳出
		if self._is_processing_tasks_changed : break
		
		# 一般任務
		if task.batch_flags.size() == 0 :
			# 是否通過
			var is_task_pass : bool = self._is_task_pass(task)
			if is_task_pass :
				self._begin_task(task)
				started_tasks[task] = true
		
		# 批次任務
		else :
			# 若確定不通過 則 忽略
			if not_pass_tasks.has(task) : continue
			# 若已開始 則 忽略
			if started_tasks.has(task) : continue
			
			# 是否通過
			var is_task_pass : bool = passed_batch_tasks.has(task)
			
			# 若 尚未視為通過
			if not is_task_pass :
				# 該任務是否通過
				is_task_pass = self._is_task_pass(task)
				# 若 不通過 則 標記不通過
				if not is_task_pass :
					not_pass_tasks[task] = true
				
				# 該任務 對應的 每個batch
				var batch_infos : Array = task_to_batch_infos[task]
				for batch_inf in batch_infos :
					# 若可忽略該batch
					if skip_batchs.has(batch_inf) : continue
					
					# batch 對應的 每個任務
					var batch_tasks : Dictionary = batch_inf["tasks"]
					
					# 該batch是否通過 (同 該任務本身有通過)
					var is_batch_pass := is_task_pass
					
					# 若 該任務本身有通過
					if is_task_pass :
						for each in batch_tasks :
							# 是否通過
							var is_pass : bool = is_task_pass
							# 若 該任務 通過 且 batch對應的任務 不為 該任務
							if is_task_pass == true and each != task :
								# 若 batch對應的任務 在 不通過任務 中 則 視為不通過
								if not_pass_tasks.has(each) :
									is_pass = false
								# 否則 判斷 batch對應的任務 本身 是否通過
								else :
									is_pass = self._is_task_pass(each)
								
							# 若 不通過 則 全部不通過
							if not is_pass :
								is_batch_pass = false
								break
					
					# 若 全部不通過
					if not is_batch_pass : 
						# 每個任務 標記不通過
						for each in batch_tasks :
							not_pass_tasks[each] = true
						# 此次任務 也視為 不通過
						is_task_pass = false
						# 下次忽略該batch
						skip_batchs[batch_inf] = true
						continue
					
					# 若 全部通過 
					#  所有 該batch的任務 都 標示通過
					for each in batch_tasks :
						if not passed_batch_tasks.has(each) :
							passed_batch_tasks[each] = true
							if each != task :
								extra_batch_tasks.push_back(each)
					
			
			# 若 該任務 通過 則 開始任務
			if is_task_pass :
				self._begin_task(task)
				if extra_batch_tasks.has(task) :
					extra_batch_tasks.erase(task)
				started_tasks[task] = true
	
	# 若有 剩餘的批次任務 尚未執行
	for task in extra_batch_tasks :
		# 開始 執行
		self._begin_task(task)
		started_tasks[task] = true
	
	# 只留下 尚未開始的 任務
	self._tasks = self._tasks.filter(func(a): return not started_tasks.has(a))
	
	# 結束 處理中
	self._is_processing = false
	
	# 若 處理中 任務有變更 則 遞迴處理
	if self._is_processing_tasks_changed :
		self._is_processing_tasks_changed = false
		self.process()


# Private ====================

# 開始 執行
func _begin_task (task) :
	
	# 移除 take標記
	for each in task.take_flags :
		var flag_info : FlagInfo = self._get_flag_info(each)
		flag_info.count -= 1
	
	# 設置 任務本身的標記
	for each in task.flags :
		var flag_info : FlagInfo = self._get_flag_info(each)
		flag_info.tasks[task] = true
	
	# 非同步執行內容
	await task.act_func.call()
	
	# 結束後 從 當前標誌 中 移除此任務
	for flag in task.flags :
		if not self._current_flags.has(flag) : continue
		var flag_info : FlagInfo = self._current_flags[flag]
		if flag_info.tasks.has(task) :
			flag_info.tasks.erase(task)
	
	# 處理 遺留標誌
	for each in task.drop_flags :
		var flag_info : FlagInfo = self._get_flag_info(each)
		flag_info.count += 1
	
	self._refresh_flags()

## 取得標記資訊
func _get_flag_info (flag: String) :
	var inf : FlagInfo = null
	if self._current_flags.has(flag) :
		inf = self._current_flags[flag]
	else :
		inf = FlagInfo.new()
		self._current_flags[flag] = inf
	return inf

## 任務是否通過
func _is_task_pass (task) :
	# 是否通過
	var is_pass := 0
	# 加入記號
	var join_symbol := "*"
	var wait_size : int = task.wait_flags.size()
	var wait_last_idx : int = wait_size - 1
	# 若有 要等待/加入的標記
	if wait_size > 0 :
		# 依倒序
		for idx in wait_size :
			var flag : String = task.wait_flags[wait_last_idx - idx]
			
			# 是否為 加入
			var is_join : bool = flag.begins_with(join_symbol)
			if is_join :
				flag = flag.left(-1)
			
			# 若 當前標記 有 要等待/加入的標記
			if self._current_flags.has(flag) :
				is_pass = 1 if is_join else -1
				break
	
	if is_pass == 0 :
		# 若 當前標記 沒有 需要的標記 則 不通過
		for flag in task.need_flags :
			if not self._current_flags.has(flag) :
				is_pass = -1
				break
	# 若通過
	return is_pass >= 0

## 刷新當前標記
func _refresh_flags () :
	# 要移除的 標記
	var to_rm := []
	# 每個 當前標記
	for flag in self._current_flags :
		var flag_info : FlagInfo = self._current_flags[flag]
		# 若 計數為 0 且 使用者列表為空 且 任務列表為空 則 加入 要移除列表
		if flag_info.count == 0 and flag_info.users.is_empty() and flag_info.tasks.is_empty() :
			to_rm.push_back(flag)
	# 移除
	for each in to_rm :
		self._current_flags.erase(each)
			
