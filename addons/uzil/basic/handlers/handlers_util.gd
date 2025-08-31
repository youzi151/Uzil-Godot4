
class CallCtrlr :
	
	var next_handlers : Array = []
	
	var tags : Array = []
	var data : Dictionary = {}
	var opts : Dictionary = {}
	
	var is_handled : bool = false
	var is_stop : bool = false
	var is_result_manual_set : bool = false
	var result = null
	
	func set_result (res) :
		self.is_result_manual_set = true
		self.result = res
	
	func stop () :
		self.is_stop = true
	
	func unhandle () :
		self.is_handled = false

class CallHandlerReturn :
	var to_wait : int = 0
	var is_all_called : bool = false
	var signal_waiter = null

# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 呼叫方法
func call_method (handlers: Array, method: StringName, args := [], opts := {}) :
	return await self.handle(handlers, args, opts.merged({
		"handle_method": method
	}))

## 處理
## data_or_args: 要被處理的資料,可被修改 或 呼叫方法的參數,不可修改. opts: 選項, 基本上不可修改.
## 可中途透過 ctrlr.next_handlers 來 新增待處理 或 刪減未被處理 的handler
func handle (handlers: Array, data_or_args = null, opts := {}) :
	var array_util = UREQ.acc(&"Uzil:Util").array
	
	# 控制項
	var ctrlr : CallCtrlr = CallCtrlr.new()
	ctrlr.opts = opts
	opts.make_read_only()
	
	# 複製 處理器列表
	handlers = handlers.duplicate()
	ctrlr.next_handlers = handlers
	
	# 是否反轉
	var is_reverse : bool = opts["is_reverse"] if opts.has("is_reverse") else false
	# 是否停止 當被處理
	var is_stop_on_handled : bool = opts["is_stop_on_handled"] if opts.has("is_stop_on_handled") else false
	# 處理方法名稱
	var handle_method : StringName = &"_handlers_handle"
	if opts.has("handle_method") :
		handle_method = opts["handle_method"]
	# 必須標籤
	var require_tags : Array = []
	if opts.has("require_tags") :
		require_tags = opts["require_tags"]
	var is_require_tags_exist : bool = require_tags.size() > 0
	# 標籤
	if opts.has("tags") :
		ctrlr.tags = opts["tags"]
	# 是否平行處理
	var is_parallel : bool = opts["is_parallel"] if opts.has("is_parallel") else false
	
	# 呼叫處理結果 容器
	var ret : CallHandlerReturn = CallHandlerReturn.new()
	
	# 若為 平行處理 則 產生 信號等候器
	if is_parallel :
		ret.signal_waiter = UREQ.acc(&"Uzil:Util").async.signal_waiter()
	
	# 是否 以參數方式呼叫
	var is_call_with_args := true
	var args := []
	var args_with_ctrlr := []
	match typeof(data_or_args) :
		TYPE_DICTIONARY :
			is_call_with_args = false
			ctrlr.data = data_or_args
			args = [data_or_args]
			args_with_ctrlr = [data_or_args, ctrlr]
		TYPE_ARRAY :
			args = data_or_args
			args_with_ctrlr = data_or_args.duplicate()
			args_with_ctrlr.push_back(ctrlr)
	
	# 每個 策略
	while handlers.size() > 0 :
		var each : Object = null
		
		# 取出 下個處理器
		each = handlers.pop_back() if is_reverse else handlers.pop_front()
		
		# 若 沒有指定處理方法 則 忽略
		if not each.has_method(handle_method) : continue
		
		# 若 有指定必須標籤 且 處理器有取得標籤方法
		if is_require_tags_exist and each.has_method(&"_handlers_get_tags") :
			# 取得處理器標籤
			var handler_tags : Array = each._handlers_get_tags()
			# 若 處理器標籤 非全包含 必須標籤 則 忽略
			if not array_util.is_contains(handler_tags, require_tags) :
				continue
		
		# 若 處理器有是否應處理方法
		if each.has_method(&"_handlers_should_handle") :
			# 若 不應處理 則 忽略
			if not each._handlers_should_handle(ctrlr) :
				continue
		
		# 標記為已經處理
		ctrlr.is_handled = true
		
		var is_use_args_with_ctrlr : bool = not (is_call_with_args and each.get_method_argument_count(handle_method) == args.size())
		var call_args : Array = args_with_ctrlr if is_use_args_with_ctrlr else args
		
		# 若為 平行處理 則 呼叫 且 不等候
		if is_parallel :
			self._call_handler(each, handle_method, call_args, ctrlr, ret)
		# 否則 呼叫 且 等候
		else :
			await self._call_handler(each, handle_method, call_args, ctrlr, ret)
		
		# 若 在被處理後停止 則 跳出
		if ctrlr.is_handled and is_stop_on_handled : break
		# 若 已終止 則 跳出
		if ctrlr.is_stop : break
	
	# 若 為 平行呼叫
	if is_parallel :
		# 標記為 已經全部呼叫
		ret.is_all_called = true
		# 若 有任一需要等候的 則 等候
		if ret.to_wait > 0 : 
			await ret.signal_waiter.until_emit()
	
	return ctrlr

func _call_handler (handler, handle_method: StringName, args: Array, ctrlr: CallCtrlr, ret: CallHandlerReturn) :
	# 增加 等候計數
	ret.to_wait += 1
	
	# 呼叫處理
	var result = await handler.callv(handle_method, args)
	# 若 有回傳結果 且 沒有手動指定過結果 則 設置 結果 為 回傳內容
	if result != null and (not ctrlr.is_result_manual_set) :
		ctrlr.result = result
	
	# 減少 等候計數
	ret.to_wait -= 1
	
	# 若已經全部呼叫 且 等候計數 歸零 則
	if ret.is_all_called and ret.to_wait == 0 : 
		# 發送信號
		if ret.signal_waiter != null : 
			ret.signal_waiter.emit()

## 排序
func sort (handlers: Array, opts := {}) :
	
	var idx_to_sort : Dictionary = {}
	
	var handler_to_info : Dictionary = {}
	
	for idx in handlers.size() :
		var each = handlers[idx]
		var sort : float = 0.0
		if each.has_method(&"_handlers_get_sort") :
			sort = each._handlers_get_sort(opts)
		elif &"_handlers_sort" in each :
			sort = each._handlers_sort
		elif each.has_meta(&"_handlers_sort") :
			sort = each.get_meta(&"_handlers_sort")
		
		handler_to_info[each] = {
			"sort":sort, 
			"idx":idx,
		}
		
	handlers.sort_custom(func(a, b):
		var info_a : Dictionary = handler_to_info[a]
		var info_b : Dictionary = handler_to_info[b]
		if info_a.sort == info_b.sort : return info_a.idx < info_b.idx
		else : return info_a.sort < info_b.sort
	)

# Private ====================
