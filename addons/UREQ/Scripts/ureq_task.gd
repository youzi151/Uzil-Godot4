## UREQ.Task 任務
## 
## 存取 某模塊的目標 並 確保該模塊的所有依賴模塊的目標也被建立並可存取.
## 

# Variable ===================

## 當 取得結果
signal on_target_got

## 主元件 暫存
var _UREQ = null

## 所屬域 暫存
var _scope = null

var access = null

## 是否為異步
var is_async := false

## 結果
var result = null
## 錯誤
var errors := []

## 是否完成
var state := 0

## 當前 請求 占用
var _current_requiring = null

# GDScript ===================

func _init (_ureq, _scope) :
	self._UREQ = _ureq
	self._scope = _scope

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 檢查錯誤
func check_error () :
	if self.state == 0 :
		if self.is_async :
			self.errors.push_back("async requires is not finished.")
		else :
			self.errors.push_back("requires is not finished.")
	
	if self.errors.size() > 0 :
		return self.errors
	else :
		return null

## 執行 存取 並 確保依賴建立
func run (access, on_done : Callable = Callable()) :
	self.access = access
	# 若 進行中
	if self.state != 0 :
		
		if self.state == 1 :
			await self.on_target_got
		
		if not on_done.is_null() :
			on_done.call(self.result)
			
		return self.result
	
	# 若 尚未檢查過
	if not access.is_requires_checked :
		
		# 建立 所屬域:依賴 表
		var scope_to_requires = self._UREQ.requires_to_dict(self._scope.key(), access.requires)
		# 蒐集 依賴的依賴
		var total_scope_to_requires = self._UREQ.collect_requires(scope_to_requires, {})
		
		# 若 依賴中 有 當前正要存取的模塊 則 視為 循環依賴
		if total_scope_to_requires.has(access.path) :
			push_error("loop requires")
			return
		
		# 排序所有依賴
		var sorted_require_list = self._UREQ.get_sort_require_list(total_scope_to_requires.values())
		
#		var debug_sorted_require_list = []
#		for each in sorted_require_list :
#			debug_sorted_require_list.push_back(each.path)
#		print("UREQ._access(%s) sorted_require_list:%s" % [access.id, debug_sorted_require_list])
		
		# 每個 依賴的存取
		for each in sorted_require_list :
			# 若 有任何依賴 為 異步
			if each.is_async :
				# 標示 此任務 為 異步
				self.is_async = true
				break
		
		# 每個 依賴的存取
		for each in sorted_require_list :
			# 異步 確保 該存取的目標 已建立
			await self._require_target(each)
			# 設為 已經檢查過依賴 (既然 已經輪到 該存取, 表示前面排序過的依賴已經被確保建立)
			each.is_requires_checked = true
		
		# 設 該存取 已經檢查過依賴
		access.is_requires_checked = true
	
	# 異步 確保 該存取的目標 已建立
	await self._require_target(access)
	
	# 設置結果
	self.result = access.target
	# 標示為已完成
	self.state = 2
	# 呼叫事件
	if not on_done.is_null() : on_done.call(self.result)
	
	self.on_target_got.emit(self.result)
	
	return self.result

# 直到 目標已取得
func until_target_got () :
	if self.state != 2 :
		await self.on_target_got
	return self.result

# Private ====================


## 確保 目標 已建立
func _require_target (access) :
	# 若 沒有忽略快取 且 已建立目標
	if not access.is_ignore_cached and access.target != null : return

	# 若 當前請求中 不存在 則 直接 當前請求中 為 此模塊
	if self._current_requiring == null :
		self._current_requiring = access.path
		
	# 若 當前請求中 存在
	else :
#		print("self._current_requiring [%s] and now [%s]" % [self._current_requiring, access.id])
		# 若 當前檢查中 與 目前即將檢查者 相同 則 視為循環 請求建立目標 並 報錯
		if self._current_requiring == access.path :
			push_error("Cycle require : %s" % access.path)
			return
	
	# 目標
	var target = null
	
	# 若 目標還未取得成功 則 以 方法 建立
	if target == null :
		if access.create_target_fn != null :
			target = await access.create_target_fn.call()
	
	# 若 目標還未取得成功 則 以 腳本 建立
	if target == null :
		var _script = self._require_access_script(access)
		if _script != null : 
#			print("require target by script : %s" % access.id)
			# 載入 模塊
			target = _script.new()
	
	# 若 目標還未取得成功 則 以 現有 建立
	if target == null :
		target = access.target
	
	# 設置 目標
	access.target = target
	
#	print("set target to "+access.target.to_string())
	
	# 解除 當前請求中
	self._current_requiring = null

## 取得 該存取的目標的腳本
func _require_access_script (access) :
	
	var is_need_reload := false
	
	# 若 目標腳本 為 空 則 需要重新讀取
	if access.target_script == null :
		is_need_reload = true
	# 若 該模塊 目標腳本 存在 且 沒有要忽略快取中的腳本 則 需要重新讀取
	elif access.target_script != null and access.is_ignore_cached_script :
		is_need_reload = true
	
	# 若 需要重新讀取
	if is_need_reload :
		access.target_script = self._UREQ.load_script(access.script_path)
		
	return access.target_script
