## UREQ.Scope 所屬域
##
## 把 模塊 劃分出 組別/所屬, 以避免命名或別名重疊.
##


# Variable ===================

## 主元件 暫存
var _UREQ = null

## 辨識
var _key := ""

## 模塊
var _accesses := []
var _id_to_access := {}

## 別名
var _alias_to_id := {}

## 當前 請求 占用
var _access_to_task := {}

# GDScript ===================

func _init (key, _ureq) :
	self._UREQ = _ureq
	self._key = key

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 關鍵字
func key () :
	return self._key

## 綁定
func bind (id : String, target, options := {}) :
	var access = self._UREQ.Access.new()
	access.id = id
	access.scope = self._key
	access.path = self._UREQ.get_access_path(self._key, id)
	
	# 依照 傳入目標 類型
	var typ = typeof(target)
	match typ :
		# 若為 字串 則是 腳本路徑
		TYPE_STRING :
			access.script_path = target
		# 若為 函式 則是 建立函式
		TYPE_CALLABLE :
			access.create_target_fn = target
		# 若為 物件 則是 目標本身
		TYPE_OBJECT :
			access.target = target
		
	if options.has("is_async") :
		access.is_async = options.is_async
	if options.has("is_ignore_cached") :
		access.is_ignore_cached = options.is_ignore_cached
	if options.has("is_ignore_cached_script") :
		access.is_ignore_cached_script = options.is_ignore_cached_script
	if options.has("requires") :
		access.requires = options.requires.duplicate()
		
	# 別名
	if options.has("alias") :
		access.alias = options.alias
	# 註冊所有別名 指向 本ID
	for each in access.alias :
		self._alias_to_id[each] = id
	
	# 紀錄 選項
	access.options = options
	
	# 加入
	self._accesses.push_back(access)
	self._id_to_access[id] = access

## 非同步 存取 並 確保依賴建立
func accync (id_or_alias : String, on_done : Callable = Callable()) :
	var access = self.get_access(id_or_alias)
	if access == null : return null
	
	# 是否 指定完成回呼
	var is_on_done_exist = not on_done.is_null()
	
	# 是否 任務存在(載入中)
	var is_task_exist = self._access_to_task.has(access)
	
	# 任務
	var task
	
	# 若 載入中
	if is_task_exist :
		# 取得 該任務
		task = self._access_to_task[access]
	else :
		# 建立 任務
		task = self._UREQ.Task.new(self._UREQ, self)
		self._access_to_task[access] = task
	
	# 回呼
	var wrap_callback : Callable
	
	# 以 Callback 方式
	if is_on_done_exist :
		wrap_callback = func (res):
			
			var result = null
			if not self._check_error(task) :
				result = task.result
				
			if not is_task_exist :
				self._access_to_task.erase(access)
				
			on_done.call(result)
		
		# 若 載入中
		if is_task_exist :
			# 註冊 信號
			task.on_target_got.connect(wrap_callback, CONNECT_ONE_SHOT)
		else :
			task.run(access, wrap_callback)
		
	# 以 async/await 方式
	else :
		# 若 尚未載入中 則
		if not is_task_exist :
			task.run(access, wrap_callback)
		
		# 等候 取得目標
		await task.until_target_got()
		
		if not is_task_exist :
			self._access_to_task.erase(access)
		
		var result = null
		if not self._check_error(task) :
			result = task.result
			
		return result

## 存取 並 確保依賴建立
func access (id_or_alias : String) :
	var access = self.get_access(id_or_alias)
	if access == null : return null
	
	var task = self._UREQ.Task.new(self._UREQ, self)
	task.run(access)
	
	var err = task.check_error()
	if err != null :
		print_debug(err)
		return null
		
	return task.result

## 取得 模塊
func get_access (id_or_alias : String) :
	# 若 存在 則 返回
	if self._id_to_access.has(id_or_alias) :
		return self._id_to_access[id_or_alias]
	if self._alias_to_id.has(id_or_alias) :
		var id : String = self._alias_to_id[id_or_alias]
		return self._id_to_access[id]
	return null

# Private =====================

func _check_error (task) :
	var err = task.check_error()
	var is_err := err != null
	if is_err :
		print_debug(err)
	return is_err
