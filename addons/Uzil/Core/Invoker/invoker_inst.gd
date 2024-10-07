
## Invoker 呼叫器
## 
## 間隔呼叫、每幀呼叫、延遲呼叫...等等
## 

var Uzil
var Invoker

# Variable ===================

## 關鍵字
var _key = "_"

## 時間實體
var _times_inst = null

## 任務列表 [br]
## 因為 跑任務時是從最舊的先，為了避免移除成員時多餘的陣列處理，所以加入時從頭，執行時從尾，頭尾調換。
var tasks : Array = []

# GDScript ===================

func _init (key: String = "_") :
	self.Uzil = UREQ.acc(&"Uzil:Uzil")
	self.Invoker = UREQ.acc(&"Uzil:Core.Invoker")
	
	self._key = key
	self._times_inst = UREQ.acc(&"Uzil:times_mgr").inst()

# Public =====================

## 推進
func process (_dt: float) :
	
	# 當前時間
	var now = self._time_now()
	
	# 所有任務 副本 (避免途中更改原任務列表而影響到迴圈)
	var _tasks = self.tasks.duplicate()
	
	# 每個任務
	for idx in _tasks.size():
		var each = _tasks[idx]
		
		# 若 被從 原任務列表 移除	
		if self.tasks.has(each) == false:
			continue
		
		# 若 沒有 要執行的內容 則 忽略
		if each.fn == null:
			continue
		
		# 依照要呼叫的類型 ###
		
		# 單次
		if each.call_type == self.Invoker.CallType.ONCE:
			
			if now > each.calltime_ms:
				self.tasks.erase(each)
				each.run()
				each.done()
			
		# 間隔
		elif each.call_type == self.Invoker.CallType.INTERVAL:
			while now > each.calltime_ms :
				each.run()
				if each.interval_ms > 0:
					each.calltime_ms = each.calltime_ms + each.interval_ms
				else:
					each.calltime_ms = now
					
		# 每幀
		elif each.call_type == self.Invoker.CallType.UPDATE:
			each.run_arg(self._times_inst.dt_sec())
		
		# 單格
		elif each.call_type == self.Invoker.CallType.FRAME:
			self.tasks.erase(each)
			each.run()

## 設置 時間實體
func set_times_inst (inst_or_key) :
	match typeof(inst_or_key) :
		TYPE_STRING :
			self._times_inst = UREQ.acc(&"Uzil:times_mgr").inst(inst_or_key)
		TYPE_OBJECT :
			self._times_inst = inst_or_key
			

## 取得 時間實體
func get_times_inst () :
	return self._times_inst

## 等候
func wait (delay_ms: int) :
	await self.once(func():pass, delay_ms).on_done

## 單次執行
func once (fn, delay_ms: int = 0) :
	var task = self.Invoker.Task.new()
	task.fn = fn
	task.calltime_ms = self._time_now() + delay_ms
	#G.print("task.calltime_ms:%s" % [task.calltime_ms])
	task.call_type = self.Invoker.CallType.ONCE
	self.tasks.push_back(task)
	self.sort()
	
	return task

## 間隔執行
func interval (fn, interval_ms: int) :
	var task = self.Invoker.Task.new()
	task.fn = fn
	task.calltime_ms = self._time_now() + interval_ms
	task.interval_ms = interval_ms
	task.call_type = self.Invoker.CallType.INTERVAL
	self.tasks.push_back(task)
	self.sort()
	
#	print("add interval :",task.get_instance_id())
	return task

## 每幀更新
func update (fn) :
	var task = self.Invoker.Task.new()
	task.fn = fn
	task.call_type = self.Invoker.CallType.UPDATE
	self.tasks.push_back(task)
	self.sort()
	return task

## 該影格僅執行一次 (以tag取代而不重複，若有排序需求建議使用Vals替代)
func frame (fn, _tag: String = "", _priority: int = 0) :
	
	var is_cancel = false
	
	# 每個
	for each in self.tasks :
		# 若 不是 相同tag的 FRAME類 任務 則 繼續
		if each.call_type != self.Invoker.CallType.FRAME or not each.tags.has(_tag):
			continue
			
		# 若 現有任務 優先度 超過 要設置的新任務 則 預計取消設置新任務 並 繼續
		if each.priority > _priority :
			is_cancel = true
			continue
			
		# 取消 該現有任務
		self.cancel_task(each)
	
	# 預計取消 新任務 則 返回
	if is_cancel :
		return
	
	var task = self.Invoker.Task.new()
	task.fn = fn
	task.call_type = self.Invoker.CallType.FRAME
	task.priority = _priority
	task.tag(_tag)
	
	self.tasks.push_back(task)
	self.sort()
	
	return task

## 取得任務
func get_task (tag: String) :
	for each in self.tasks :
		if each.tags.has(tag) : return each

## 取得多個任務
func get_tasks (tag: String) :
	var res := []
	# 每個
	for each in self.tasks :
		if each.tags.has(tag) : res.push_back(each)
	return res

## 以 標籤 取消
func cancel_tag (tag: String) :
	# 每個 (從末端)
	var size : int = self.tasks.size()
	var last : int = size - 1
	for idx in size :
		var each = self.tasks[last - idx]
		if each.tags.has(tag) : self.tasks.erase(each)
	

## 以 任務 取消
func cancel_task (task, is_safe_mode := true) :
	if not self.tasks.has(task) and is_safe_mode: 
		push_warning("InvokerInst.cancel_task : task not in tasks")
	self.tasks.erase(task)

## 排序
func sort () :
	
	# 依序推進的自動排序依據
	var auto_sort : int = 0
	
	# 每個 (從首端)
	for each in self.tasks :
		# 若沒有手動排序 則 將 當前位置 作為 排序依據
		if each.sort == 0:
			each.auto_sort = auto_sort
			auto_sort = auto_sort + 1
	
	# 排序 越大越前(實際上是尾端)
	self.tasks.sort_custom(func(a,b):
		
		# 若其中一方 具 手動排序 則
		if a.sort != 0 or b.sort != 0:
			return a.sort < b.sort
		# 否則 以 自動排序
		else:
			return a.auto_sort < b.auto_sort
	)

func _time_now () :
	return self._times_inst.now()
