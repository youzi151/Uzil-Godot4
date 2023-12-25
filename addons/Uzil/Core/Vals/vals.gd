
## Vals 多重數值
##
## 註冊多個使用者與數值, 並取得優先度最高的來作為當前數值.
##

# Variable ===================

## 預設值
var _default_val = null

## 使用者 : 資料表
var _user_to_data := {}

## 過濾標籤
var _filter_ptags := []
var _filter_ntags := []

## 當前值 修改函式
var _current_modifier_fn = null

## 當前值
var _current_val = null
## 當前使用者
var _current_user = null
## 當前資料
var _current_data = null


## 當 更新 (與當前值可能有關的)
var on_update = null

# GDScript ===================

func _init () :
	var Evt = UREQ.acc("Uzil", "Core.Evt")
	self.on_update = Evt.Inst.new()

# Public =====================

## 取得 數量
func size () :
	return self._user_to_data.size()

## 取得 當前值 (若是 函式 則 呼叫取值) [br]
## 如要取得函式本身作為值而非呼叫, 可用Dictionary包裝.
func current () :
	# 依照類型 取得 當前值
	var curr = null
	if typeof(self._current_val) == TYPE_CALLABLE :
		curr = self._current_val.call()
	else :
		curr = self._current_val
		
	# 若 當前值覆寫函式 存在 則 覆寫
	if self._current_modifier_fn != null :
		curr = self._current_modifier_fn.call({
			"val": curr,
			"user": self._current_user
		})
	
	return curr

## 取得 當前使用者
func current_user () :
	return self._current_user

## 設置 過濾標籤
func set_filters (filters : Array) :
	self._filter_ptags.clear()
	self._filter_ntags.clear()
	for each in filters :
		if each.begins_with("-") :
			self._filter_ntags.push_back(each.substr(1))
		else :
			self._filter_ptags.push_back(each)
	self._update_users()

## 設置 當前資料覆寫函式
func set_current_modifier_fn (fn) :
	
	self._current_modifier_fn = fn
	
	self.on_update.emit()

## 設置	
func set_data (user, val, _priority = 0) :
	
	var data = self.get_data(user)
	
	# 是否有更動 優先度
	var is_priority_changed := false
	
	# 若 已存在
	if data != null :
		
		data.val = val
		
		is_priority_changed = data.pri != _priority
		data.pri = _priority
		
	# 否則 新建立
	else :
		data = {
			"val" : val,
			"pri" : _priority,
			"tags" : [],
		}
		self._user_to_data[user] = data
		
		is_priority_changed = true
	
	# 若 有更新優先度 則 刷新 (以此資料單獨比對)
	if is_priority_changed :
		self._update_users()

## 設置預設
func set_default (val) :
	self._default_val = val
	if self._user_to_data.size() == 0 :
		self._update_current(null, null)

## 設置
func set_val (user, val) :
	var data = self.get_data(user)
	if data == null : return
	data.val = val
	if user == self._current_user :
		self._update_current(self._current_user)

## 設置 優先度
func set_pri (user, priority : int) :
	var data = self.get_data(user)
	if data == null : return
	data.pri = priority
	self._update_users()

## 設置 標籤
func set_tags (user, tags : Array) :
	var data = self.get_data(user)
	if data == null : return
	data.tags = tags.duplicate()
	self._update_users()

## 取得
func get_data (user) :
	if user == null : return null
	if self._user_to_data.has(user) : 
		return self._user_to_data[user]
	return null

## 移除
func del_data (user) :
	var data = self.get_data(user)
	if data == null : return
	
	# 移除的 是否為當前使用者
	var is_current_user = (user == self._current_user)
	
	# 移除
	self._user_to_data.erase(user)
	
	# 若 移除的 為 當前使用者 則 清除當前
	if is_current_user :
		self.clear_current(false)
		self.update()

## 清空
func clear () :
	self.clear_current()
	self._user_to_data.clear()

## 清空當前
func clear_current (_is_need_update = true) :
	self._current_user = null
	self._current_data = null
	self._current_val = null
	
	if _is_need_update :
		self.on_update.emit()

## 刷新
func update () :
	self._update_users()

## 刷新 用戶
func _update_users () :
	var user_to_data_filtered := {}
	# 每筆註冊資料
	for user in self._user_to_data :
		var data = self._user_to_data[user]
		var tags = data.tags
		
		# 是否排除
		var is_exclude := false
		
		# 若 正面標籤 存在
		if self._filter_ntags.size() > 0 :
			# 每個 要篩選的負面標籤
			for ntag in self._filter_ntags :
				# 若 該註冊資料的標記 包含 要篩選的負面標籤 則 加入排除
				if tags.has(ntag) :
					is_exclude = true
					break
					
		if is_exclude : continue
		
		# 若 正面標籤 存在
		if self._filter_ptags.size() > 0 :
			is_exclude = true
			# 每個 要篩選的正面標籤
			for ptag in self._filter_ptags :
				if tags.has(ptag) :
					is_exclude = false
					break
					
		if is_exclude : continue
		
		user_to_data_filtered[user] = data
	
	# 依照 使用者 數量 有不同執行
	match user_to_data_filtered.size() :
		# 沒有使用者 設置預設
		0 :
			self.clear_current(true)
			self._update_current(null)
			
		# 單個使用者 直接設置
		1 :
			var user_only = user_to_data_filtered.keys()[0]
			self._update_current(user_only)
			
		# 多個使用者 進行比較
		_ :
			var users = user_to_data_filtered.keys()
			var most_user = users[0]
			var most_pri = user_to_data_filtered[most_user].pri
			
			for each_user in users:
				var each = user_to_data_filtered[each_user]
				if each.pri > most_pri :
					most_pri = each.pri
					most_user = each_user
				
			self._update_current(most_user)

## 更新 當前
func _update_current (curr_user, _curr_data = null) :
	
	# 是否 改變
	var is_changed : bool
	
	# 若 使用者 不同 則 變更
	if self._current_user != curr_user :
		# 變更
		self._current_user = curr_user
		# 設 有改變
		is_changed = true
	
	# 若 使用者 存在 且 沒有指定 資料 且 查得到該使用者資料
	if curr_user != null and _curr_data == null and self._user_to_data.has(curr_user) :
		# 指定資料
		_curr_data = self._user_to_data[curr_user]
	
	# 若 資料 不同 則 變更
	if self._current_data != _curr_data :
		self._current_data = _curr_data
	
	# 值
	var val
	if self._current_data == null :
		val = self._default_val
	else :
		val = self._current_data.val
	
	# 若 值 不同 則 變更
	if typeof(self._current_val) != typeof(val) or self._current_val != val :
		# 變更
		self._current_val = val
		# 設 有改變
		is_changed = true
	
	if is_changed :
		self.on_update.emit()
