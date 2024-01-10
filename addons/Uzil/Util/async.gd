
## async 異步執行
##
## 設計參考自async.js
## 

class WaitSignal :
	var is_done : bool = false
	signal sign
	func until_done () :
		if not self.is_done : await self.sign
	func emit () :
		self.is_done = true
		self.sign.emit()

## 每個成員
func each (list_or_dict, fn_each, _fn_done = null) :
	
	# 總數
	var count = list_or_dict.size()
	
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
	var each_done = func () :
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
		
		# 傳入參考
		var ref2 := {}
		# 是否已呼叫下一個任務
		ref2.is_next_called = false
		
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func():
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func():
			ref1.state = 2
			ctrlr.next.call()
		# 下一個
		ctrlr.next = func():
			# 防止重複呼叫
			if ref2.is_next_called : return
			ref2.is_next_called = true
			
			# 清空 控制器
			ctrlr.clear()
			
			each_done.call()
			
		# 執行 並 傳入 呼叫下一任務的func
		fn_each.call(cur_idx, each_ele, ctrlr)
	
	if _fn_done == null : await wait_until_done.until_done()

## 每個列表成員 依序
func each_series (list_or_dict, fn_each, _fn_done = null) :
	
	# 總數
	var count = list_or_dict.size()
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 索引
	var indexes = null
	match typeof(list_or_dict) :
		TYPE_ARRAY :
			indexes = range(0, count)
		TYPE_DICTIONARY :
			indexes = list_or_dict.keys()
		
	if indexes == null or indexes.size() == 0:
		# 執行最後任務
		if _fn_done != null:
			_fn_done.call()
		return
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 下一個
	ref1.nextFunc = func(num):
		var nxt_num = num + 1
		
		# 索引
		var cur_idx = indexes[num]
		
		# 傳入參考
		var ref2 := {}
		# 是否已呼叫下一個任務
		ref2.is_next_called = false
		
		# 控制器
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func():
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func():
			ref1.state = 2
			ctrlr.next.call()
			
		# 下一個任務
		ctrlr.next = func():
			# 防止重複呼叫
			if ref2.is_next_called : return
			ref2.is_next_called = true
			
			# 清空 控制器
			ctrlr.clear()
			
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
			ctrlr.next.call()
			return
		
		# 每個
		var each_ele = list_or_dict[cur_idx]
		
		# 呼叫當前任務 傳入 呼叫下一任務的func
		fn_each.call(cur_idx, each_ele, ctrlr)
	
	# 呼叫 首個任務
	ref1.nextFunc.call(0)
	
	
	if _fn_done == null : await wait_until_done.until_done()

## 執行次數
func times (run_times, fn_each, _fn_done = null) :
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 剩餘倒數
	ref1.left_count = run_times
	# 狀態
	ref1.state = 0
	
	# 每個呼叫
	var each_call = func(idx) :
		
		# 傳入參考
		var ref2 := {}
		# 是否已經呼叫過next
		ref2.is_next_called = false
		
		# 控制器
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func():
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func():
			ref1.state = 2
			ctrlr.next.call()
		# 下一個
		ctrlr.next = func():
			# 避免重複呼叫nxt
			if ref2.is_next_called : return
			ref2.is_next_called = true
		
			# 清空 控制器
			ctrlr.clear()
			
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
func times_series (run_times, fn_each, _fn_done = null) :
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 每個呼叫
	ref1.each_call = func(idx) :
		
		# 序號暫存
		var cur_idx : int = idx
		var nxt_idx : int = idx + 1
		
		# 傳入參考
		var ref2 := {}
		# 是否已經呼叫過next
		ref2.is_next_called = false
		
		# 控制器
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func():
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func():
			ref1.state = 2
			ctrlr.next.call()
		# 下一個
		ctrlr.next = func():
			# 避免重複呼叫nxt
			if ref2.is_next_called : return
			ref2.is_next_called = true
			
			# 清空 控制器
			ctrlr.clear()
			
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
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 剩餘倒數
	ref1.left_count = count
	# 狀態 0:繼續 1:跳過 2:停止
	ref1.state = 0
	
	# 每當執行完畢
	var each_done := func () :
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
		
		# 傳入參考
		var ref2 := {}
		# 是否已呼叫下一個任務
		ref2.is_next_called = false
		
		# 控制器
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func () :
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func () :
			ref1.state = 2
			ctrlr.next.call()
		# 下一個
		ctrlr.next = func () :
			# 防止重複呼叫
			if ref2.is_next_called : return
			ref2.is_next_called = true
			
			# 清空 控制器
			ctrlr.clear()
			
			each_done.call()
			
		# 執行 並 傳入 呼叫下一任務的func
		fn_each.call(ctrlr)
		
	if _fn_done == null : await wait_until_done.until_done()

## 執行任務 依序
func waterfall (fn_list, _fn_done = null) :
	
	var wait_until_done : WaitSignal = null
	if _fn_done == null : wait_until_done = WaitSignal.new()
	
	# 傳入參考
	var ref1 := {}
	# 狀態
	ref1.state = 0
	
	# 下一個任務
	ref1.nextFunc = func(idx):
		# 任務
		var fn = fn_list[idx]
		# 下一任務序號
		var next_idx = idx + 1
		
		# 傳入參考
		var ref2 := {}
		# 是否已呼叫下一個任務
		ref2.is_next_called = false
		
		# 控制器
		var ctrlr := {}
		# 跳過
		ctrlr.skip = func () :
			ref1.state = 1
			ctrlr.next.call()
		# 停止
		ctrlr.stop = func () :
			ref1.state = 2
			ctrlr.next.call()
		# 下一個任務
		ctrlr.next = func():
			# 防止重複呼叫
			if ref2.is_next_called : return
			ref2.is_next_called = true
			
			# 清空 控制器
			ctrlr.clear()
			
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
