
class CallCtrlr :
	
	var handlers : Array = []
	
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

# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 呼叫 函式
func call_method (handlers: Array, method: StringName, args := [], opts := {}) :
	handlers = handlers.duplicate()
	
	opts = self._get_options(opts)
	var is_reverse : bool = opts["is_reverse"]
	var is_stop_on_handled : bool = opts["is_stop_on_handled"]
	var on_each_done : Callable = opts["on_each_done"]
	var is_debug := false
	if opts.has("debug") : is_debug = true
	
	var ctrlr : CallCtrlr = CallCtrlr.new()
	ctrlr.handlers = handlers
	ctrlr.opts = opts
	
	var args_copy := args.duplicate()
	var args_count := args_copy.size()
	
	var args_with_ctrlr := args.duplicate()
	args_with_ctrlr.push_back(ctrlr)
	var args_with_ctrlr_count := args_count + 1
	
	# 每個 策略
	while handlers.size() > 0 :
		var each : Object = null
		if is_reverse :
			each = handlers.pop_back()
		else :
			each = handlers.pop_front()
		
		# 若 無實作 方法 則 繼續下個策略
		#G.print("%s has %s ? %s" % [each, method, each.has_method(method)])
		if not each.has_method(method) : continue
		
		ctrlr.is_handled = true
		
		# 呼叫 該方法
		var each_res = null
		var method_args_count : int = each.get_method_argument_count(method)
		if method_args_count == args_with_ctrlr_count:
			each_res = each.callv(method, args_with_ctrlr)
		else :
			each_res = each.callv(method, args_copy)
		
		# 若 有回傳結果 且 沒有手動指定過結果 則 設置 結果 為 回傳內容
		if each_res != null and (not ctrlr.is_result_manual_set) :
			ctrlr.result = each_res
		
		# 呼叫 當每個完成
		if not on_each_done.is_null() :
			on_each_done.call(ctrlr)
		
		# 若 在被處理後停止 則 跳出
		if ctrlr.is_handled and is_stop_on_handled : break
		# 若 已終止 則 跳出
		if ctrlr.is_stop : break
	
	if is_debug : 
		G.print("handlers.size() == %s" % [handlers.size()])
	
	return ctrlr

## 處理
## data: 要被處理的資料, 可被修改. opts: 選項, 基本上不可修改.
func handle (handlers: Array, tags: Array, data := {}, opts := {}) :
	handlers = handlers.duplicate()
	
	opts = self._get_options(opts)
	var is_reverse : bool = opts["is_reverse"]
	var is_stop_on_handled : bool = opts["is_stop_on_handled"]
	
	var handle_method : StringName = &"_handlers_handle"
	
	var array_util = UREQ.acc(&"Uzil:Util").array
	
	var ctrlr : CallCtrlr = CallCtrlr.new()
	ctrlr.tags = tags
	ctrlr.data = data
	ctrlr.opts = opts
	opts.make_read_only()
	
	# 每個 策略 (從末端)
	while handlers.size() > 0 :
		var each : Object = null
		if is_reverse :
			each = handlers.pop_back()
		else :
			each = handlers.pop_front()
		
		if not each.has_method(handle_method) : continue
		
		var require_tags : Array = []
		if opts.has("require_tags") :
			require_tags = opts["require_tags"]
		
		if require_tags.size() > 0 and each.has_method(&"_handlers_get_tags") :
			var handler_tags : Array = each._handlers_get_tags()
			if not array_util.is_contains(handler_tags, require_tags) :
				continue
		
		if each.has_method(&"_handlers_should_handle") :
			if not each._handlers_should_handle(ctrlr) :
				continue
		
		ctrlr.is_handled = true
		
		# 呼叫 該方法
		var each_res = each.callv(handle_method, [ctrlr])
		# 若 有回傳結果 且 沒有手動指定過結果 則 設置 結果 為 回傳內容
		if each_res != null and (not ctrlr.is_result_manual_set) :
			ctrlr.result = each_res
		
		# 若 在被處理後停止 則 跳出
		if ctrlr.is_handled and is_stop_on_handled : break
		# 若 已終止 則 跳出
		if ctrlr.is_stop : break
	
	return ctrlr

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

func _get_options (opts := {}) :
	var new_opts := opts.duplicate()
	
	if not new_opts.has("is_stop_on_handled") :
		new_opts["is_stop_on_handled"] = false
	if not new_opts.has("is_reverse") :
		new_opts["is_reverse"] = false
	if not new_opts.has("on_each_done") :
		new_opts["on_each_done"] = Callable()
	
	return new_opts
	
