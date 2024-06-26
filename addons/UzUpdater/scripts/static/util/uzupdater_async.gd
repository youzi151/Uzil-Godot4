
## async 異步執行
##
## 複製來自 Uzil.Util.Async.[br]
## 設計參考自async.js
## 

class Ctrlr :
	var is_active : bool = true
	var skip_fn : Callable
	var stop_fn : Callable
	var next_fn : Callable
	func skip () :
		if not self.is_active : return
		self.skip_fn.call()
	func stop () :
		if not self.is_active : return
		self.stop_fn.call()
	func next () :
		if not self.is_active : return
		self.next_fn.call()
	func deactive () :
		self.is_active = false

class WaitSignal :
	var is_done : bool = false
	signal sign
	func until_done () :
		if not self.is_done : await self.sign
	func emit () :
		self.is_done = true
		self.sign.emit()

## 每個成員
func each (list_or_dict, fn_each: Callable, _fn_done = null) :
	
	# 總數
	var count = list_or_dict.size()
	
	# 防呆
	if count == 0:
		# 執行最後任務
		if _fn_done != null:
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 索引
	var indexes
	match typeof(list_or_dict) :
		TYPE_ARRAY :
			indexes = range(0, count)
		TYPE_DICTIONARY :
			indexes = list_or_dict.keys()
		_ : 
			return
	
	# 傳入參考
	var ref1 := {}
	# 剩餘倒數
	ref1.left_count = count
	# 狀態
	ref1.state = 0
	
	# 每當執行完畢
	var each_done := func():
		# 若 狀態 結束 則 返回
		if ref1.state == 2 : return
		
		# 倒數
		var left_count = ref1.left_count - 1
		ref1.left_count = left_count
		
		# 若 狀態 跳過 或 倒數完畢
		if ref1.state == 1 or left_count <= 0 :
			# 標記 狀態 已結束
			ref1.state = 2
			# 執行最後任務
			if _fn_done != null :
				_fn_done.call()
			else :
				wait_until_done.emit()
		
	
	# 每個任務
	for num in range(0, indexes.size()) :
		
		# 序號暫存
		var cur_idx = indexes[num]
		
		# 若 成員 已經不存在 則 視為完成 並 跳過
		var is_exist
		match typeof(list_or_dict) :
			TYPE_ARRAY :
				is_exist = cur_idx < list_or_dict.size()
			TYPE_DICTIONARY :
				is_exist = list_or_dict.has(cur_idx)
		if not is_exist : 
			each_done.call()
			return
		
		# 成員
		var each_ele = list_or_dict[cur_idx]
		
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
		# 下一個
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			each_done.call()
			
		# 執行 並 傳入 呼叫下一任務的func
		fn_each.call(cur_idx, each_ele, ctrlr)
	
	if _fn_done == null : await wait_until_done.until_done()

## 每個列表成員 依序
func each_series (list_or_dict, fn_each: Callable, _fn_done = null) :
	
	# 總數
	var count = list_or_dict.size()
	# 防呆
	if count == 0:
		# 執行最後任務
		if _fn_done != null:
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 索引
	var indexes = null
	match typeof(list_or_dict) :
		TYPE_ARRAY :
			indexes = range(0, count)
		TYPE_DICTIONARY :
			indexes = list_or_dict.keys()
		
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 下一個
	ref1.nextFunc = func(num: int):
		var nxt_num = num + 1
		
		# 索引
		var cur_idx = indexes[num]
		
		# 控制器
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
			
		# 下一個任務
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			# 若 狀態 停止 則 返回
			if ref1.state == 2 : return
			
			# 若 狀態 跳過 或 已抵達最後一個
			if ref1.state == 1 or nxt_num >= count:
				# 執行最後任務
				if _fn_done != null:
					_fn_done.call()
				else :
					wait_until_done.emit()
			# 若 還有任務
			else:
				# 呼叫下一個任務
				ref1.nextFunc.call(nxt_num)
		
		
		# 若 成員 已經不存在 則 視為完成 並 跳過
		var is_exist
		match typeof(list_or_dict) :
			TYPE_ARRAY :
				is_exist = cur_idx < list_or_dict.size()
			TYPE_DICTIONARY :
				is_exist = list_or_dict.has(cur_idx)
		if not is_exist : 
			ctrlr.next()
			return
		
		# 每個
		var each_ele = list_or_dict[cur_idx]
		
		# 呼叫當前任務 傳入 呼叫下一任務的func
		fn_each.call(cur_idx, each_ele, ctrlr)
	
	# 呼叫 首個任務
	ref1.nextFunc.call(0)
	
	
	if _fn_done == null : await wait_until_done.until_done()

## 執行次數
func times (run_times: int, fn_each: Callable, _fn_done = null) :
	if run_times == 0 :
		if _fn_done != null :
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 剩餘倒數
	ref1.left_count = run_times
	# 狀態
	ref1.state = 0
	
	# 每個呼叫
	var each_call := func(idx: int):
		
		# 控制器
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
		# 下一個
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			# 若 狀態 結束 則 返回
			if ref1.state == 2 : return
			
			# 倒數
			var left_count = ref1.left_count - 1
			ref1.left_count = left_count
			
			# 若 狀態 跳過 或 倒數完畢
			if ref1.state == 1 or left_count <= 0 :
				# 標記 狀態 已結束
				ref1.state = 2
				# 執行 最後任務
				if _fn_done != null :
					_fn_done.call()
				else :
					wait_until_done.emit()
		
		# 呼叫 任務 傳入 呼叫下一個的fn
		fn_each.call(idx, ctrlr)
	
	# 呼叫多次
	for idx in range(0, run_times):
		each_call.call(idx)
	
	if _fn_done == null : await wait_until_done.until_done()


## 執行次數 依序
func times_series (run_times: int, fn_each: Callable, _fn_done = null) :
	if run_times == 0 :
		if _fn_done != null :
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 每個呼叫
	ref1.each_call = func(idx: int):
		
		# 序號暫存
		var cur_idx : int = idx
		var nxt_idx : int = idx + 1
		
		# 控制器
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
		# 下一個
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			# 若 狀態 結束 則 返回
			if ref1.state == 2 : return
		
			# 若 狀態 跳過 或 已達執行次數
			if ref1.state == 1 or nxt_idx >= run_times :
				# 執行 最後任務
				if _fn_done != null :
					_fn_done.call()
				else :
					wait_until_done.emit()
			else:
				ref1.each_call.call(nxt_idx)
		
		# 呼叫 任務 傳入 呼叫下一個的fn
		fn_each.call(cur_idx, ctrlr)
	
	ref1.each_call.call(0)
	
	if _fn_done == null : await wait_until_done.until_done()

## 執行任務
func parallel (fn_list, _fn_done = null) :
	
	# 總數
	var count : int = fn_list.size()
	
	if count == 0 :
		if _fn_done != null :
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 剩餘倒數
	ref1.left_count = count
	# 狀態 0:繼續 1:跳過 2:停止
	ref1.state = 0
	
	# 每當執行完畢
	var each_done := func():
		# 若已經結束 則 返回
		if ref1.state == 2 : return
		
		# 倒數
		var left_count : int = ref1.left_count - 1
		ref1.left_count = left_count
		
		# 若 狀態 跳過 或 倒數完畢
		if ref1.state == 1 or left_count <= 0 :
			# 標記 狀態 已結束
			ref1.state = 2
			# 執行最後任務
			if _fn_done != null :
				_fn_done.call()
			else :
				wait_until_done.emit()
	
	# 每個任務
	for idx in range(0, count) :
		
		# 任務
		var fn_each = fn_list[idx]
		
		# 控制器
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
		# 下一個
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			each_done.call()
			
		# 執行 並 傳入 呼叫下一任務的func
		fn_each.call(ctrlr)
		
	if _fn_done == null : await wait_until_done.until_done()

## 執行任務 依序
func waterfall (fn_list, _fn_done = null) :
	
	if fn_list.size() == 0 :
		if _fn_done != null :
			_fn_done.call()
		return
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 下一個任務
	ref1.nextFunc = func(idx: int):
		# 任務
		var fn = fn_list[idx]
		# 下一任務序號
		var next_idx = idx + 1
		
		# 控制器
		var ctrlr : Ctrlr = Ctrlr.new()
		# 跳過
		ctrlr.skip_fn = func():
			ref1.state = 1
			ctrlr.next()
		# 停止
		ctrlr.stop_fn = func():
			ref1.state = 2
			ctrlr.next()
		# 下一個任務
		ctrlr.next_fn = func():
			# 關閉 控制器
			ctrlr.deactive()
			
			# 若 狀態為停止 則 返回
			if ref1.state == 2 : return
			
			# 若 狀態為跳過 或 已抵達最後一個
			if ref1.state == 1 or next_idx >= fn_list.size() :
				
				# 執行最後任務
				if _fn_done != null:
					_fn_done.call()
				else :
					wait_until_done.emit()
					
			# 若 還有任務
			else:
				# 呼叫下一個任務
				ref1.nextFunc.call(next_idx)
		
		# 呼叫當前任務 傳入 呼叫下一任務的func
		fn.call(ctrlr)
	
	# 呼叫 首個任務
	ref1.nextFunc.call(0)
	
	if _fn_done == null : await wait_until_done.until_done()
