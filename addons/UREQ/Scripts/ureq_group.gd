
# Variable ===================

var UREQ = null

## 模塊
var accesses := []
var id_to_access := {}

## 別名
var alias_to_id := {}

## 當前 請求 占用
var _current_requiring = null

var _access_id_to_on_target_created_fn := {}

# GDScript ===================

func _init (_ureq) :
	self.UREQ = _ureq

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 綁定
func bind (id : String, target, options := {}) :
	var access = self.UREQ.Access.new()
	
	access.id = id
	
	var typ = typeof(target)
	match typ :
		TYPE_STRING :
			access.script_path = target
		TYPE_CALLABLE :
			access.create_target_fn = target
		TYPE_OBJECT :
#			if target is GDScript :
#				access.target_script = target
#			else :
				access.target = target
		
	if options.has("access_type") :
		access.access_type = options.access_type
	if options.has("is_runtime_load") :
		access.is_runtime_load = options.is_runtime_load
	if options.has("is_lazy") :
		access.is_lazy = options.is_lazy
	if options.has("requires") :
		access.requires = options.requires.duplicate()
	
	if options.has("alias") :
		access.alias = options.alias
	
	self.accesses.push_back(access)
	self.id_to_access[id] = access
	
	for each in access.alias :
		self.alias_to_id[each] = id

## 安裝 [br]
## 因為沒有要注入, 所以只有建立non_lazy的access
func install () :
	
	var sorted_access_id_list = self._sort_require_id_list(self.accesses)
	
#	print("[UREQ] total sorted DI install access : "+str(sorted_access_id_list))
	for access_id in sorted_access_id_list :
		
		var access = self.id_to_access[access_id]
			
		if not access.is_lazy :
#			print("not lazy require:"+access_id)
			self._access(access)
	
## 存取 並 確保依賴建立
func access (id_or_alias) :
	var access = self._get_access(id_or_alias)
	if access == null : return null
	return self._access(access)

func _access (access) :
	
	if not access.is_requires_checked :
		
		# 蒐集 依賴的依賴
		var requires = self._collect_requires(access.requires, {})
		
		if requires.has(access.id) :
			push_error("loop requires")
			return
		
		# 排序所有依賴
		var sorted_require_id_list = self._sort_require_id_list(requires.values())
		
		# 每個 依賴的存取
		for each_id in sorted_require_id_list :
			var access_required = requires[each_id]
			# 確保 該存取的目標 已建立
			self._require_target(access_required)
			# 設為 已經檢查過依賴 (既然 已經輪到 該存取, 表示前面排序過的依賴已經被確保建立)
			access_required.is_requires_checked = true
		
		# 設 該存取 已經檢查過依賴
		access.is_requires_checked = true
	
	return self._access_target(access)

## 存取 目標
func _access_target (access) :
	
	# 確保 目標 已建立
	self._require_target(access)
	
	# 依照 存取類型
	var AccessType = self.UREQ.AccessType
	match access.access_type :
		# 預設 及 單例
		AccessType.DEFAULT, AccessType.SINGLETON :
			return access.target
		# 物件池
		AccessType.POOL :
			return access.target.reuse()

## 確保 目標 已建立
func _require_target (access) :
	# 若 尚未建立 目標
	if access.target != null : return
	
	# 檢查 是否請求中
	if self._current_requiring != null :

#		print("self._current_requiring [%s] and now [%s]" % [self._current_requiring, access.id])
		
		# 若 當前檢查中 與 目前即將檢查者 相同 則 視為循環 請求建立目標 並 報錯
		if self._current_requiring == access.id :
			push_error("Cycle require : %s" % access.id)
			return
		
	else :
		self._current_requiring = access.id
	
	# 以 方法 建立
	if access.target == null :
		if access.create_target_fn != null :
			access.target = access.create_target_fn.call()
	
	# 以 腳本 建立
	if access.target == null :
		var _script = self.require_access_script(access)
		if _script != null : 
	#		print("require target by script : %s" % access.id)
			# 載入 模塊
			access.target = _script.new()
	
	self._current_requiring = null


## 取得 該存取的腳本
func require_access_script (access) :
	
	if access.target_script != null :
		if access.is_runtime_load :
			access.target_script = null
	
	if access.target_script == null :
		access.target_script = self.UREQ.load_script(access.script_path)
		
	return access.target_script

## 蒐集 依賴資訊
func _collect_requires (requires, collected := {}) :
	# 每個 依賴
	for each_id_or_alias in requires :
		# 若 已被加入 則 忽略
		if collected.has(each_id_or_alias) : continue
		
		var each_access = self._get_access(each_id_or_alias)
		
		# 若 已被加入 則 忽略
		if collected.has(each_access.id) : continue
		
		collected[each_access.id] = each_access
		
		# 若 該存取 尚未被檢查過依賴 則 遞迴蒐集
		if not each_access.is_requires_checked :
			self._collect_requires(each_access.requires, collected)
		
	return collected

func _sort_require_id_list (_accesses : Array) :
	## 卡恩演算法
	var queue := []
	var sorted_access_id_list := []
	var dependencies := {}
	
	for access in _accesses :
		
		var dependency := {}
		for each in access.requires :
			var each_require = self._get_access(each)
			if not dependency.has(each_require.id) :
				dependency[each_require.id] = true
		
		dependencies[access.id] = dependency.keys()
		
		if access.requires.size() == 0 :
			queue.push_back(access.id)
	
	while queue.size() > 0 :
		var access_id = queue.pop_front()
		sorted_access_id_list.push_back(access_id)
		
		# 若 已經處理過 則 忽略
		if not dependencies.has(access_id) : continue
		dependencies.erase(access_id)
		
		# 檢查下一輪 是否有 
		for each_id in dependencies :
			var each_access_requires = dependencies[each_id]
			if each_access_requires.has(access_id) :
				each_access_requires.erase(access_id)
			
			if each_access_requires.size() == 0 and not queue.has(each_id) :
				queue.push_back(each_id)
			
	if dependencies.size() > 0 :
		push_error("Cyclic dependencies exist, unable to perform linear sorting")
		push_error(dependencies)
		return
	
	return sorted_access_id_list

## 取得 模塊
func _get_access (id_or_alias : String) :
	# 若 存在 則 返回
	if self.id_to_access.has(id_or_alias) :
		return self.id_to_access[id_or_alias]
	if self.alias_to_id.has(id_or_alias) :
		var id : String = self.alias_to_id[id_or_alias]
		return self.id_to_access[id]
	

# Private ====================

