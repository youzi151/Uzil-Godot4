
## Vals 多重數值
##
## 註冊多個使用者與數值, 並取得優先度最高的來作為當前數值.
##

# Variable ===================

## 預設值
var _default_val = null

## 使用者 : 資料表
var _user_to_data := {}

## 當前值 覆寫函式
var _current_overwrite_fn = null

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
func count () :
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
	if self._current_overwrite_fn != null :
		curr = self._current_overwrite_fn.call({
			"val": curr,
			"user": self._current_user
		})
	
	return curr

## 取得 當前使用者
func current_user () :
	return self._current_user

## 設置 當前資料覆寫函式
func set_current_overwrite_fn (fn) :
	
	self._current_overwrite_fn = fn
	
	self.on_update.emit()

## 設置
func set_data (val, user, _priority = 0) :
	
	var data = self.get_data(user)
	
	# 是否有更動 優先度
	var is_priority_changed = false
	
	# 若 已存在
	if data != null :
		
		data.val = val
		
		is_priority_changed = data.pri != _priority
		data.pri = _priority
		
	# 否則 新建立
	else :
		data = {
			"val" : val,
			"pri" : _priority
		}
		self._user_to_data[user] = data
		
		is_priority_changed = true
	
	# 若 有更新優先度 則 刷新 (以此資料單獨比對)
	if is_priority_changed :
		self._update_with(user, data)

## 設置預設
func set_default (val) :
	self._default_val = val
	if self._user_to_data.size() == 0 :
		self._update_current(null, null)

## 設置 優先度
func set_pri (user, priority) :
	var data = self.get_data(user)
	if data == null : return
	data.pri = priority
	self._update_with(user, data)

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
		self.on_update.call()

## 刷新
func update () :
	self._update_with(null, null)

## 刷新 (與 特定使用者,資料 比對)
func _update_with (user, data) :
	
	# 若有 指定比對
	if user != null and data != null :
		
		# 若 特定使用者 與 當前使用者 不同
		if self._current_user != user :
			# 若 當前使用者,資料 存在
			if self._current_user != null :
				# 若 該資料 優先度 小於 當前使用者
				if data.pri < self._current_data.pri :
					# 視為 不影響 當前狀態 可忽略
					return
		
		# 替換 當前使用者, 資料
		self._update_current(user, data)
		
	else :
		# 依照 使用者 數量 有不同執行
		match self._user_to_data.size() :
			# 沒有使用者 設置預設
			0 :
				self.clear_current(false)
				self._update_current(null)
				
			# 單個使用者 直接設置
			1 :
				var user_only = self._user_to_data.keys()[0]
				self._update_current(user_only)
				
			# 多個使用者 進行比較
			_ :
				var users = self._user_to_data.keys()
				var most_pri = self._user_to_data.values()[0].pri
				var most_user = null
				
				for each_user in users:
					var each = self._user_to_data[each_user]
					if each.pri > most_pri :
						most_pri = each.pri
						most_user = each_user
					
				self._update_current(most_user)

## 更新 當前
func _update_current (curr_user, _curr_data = null) :
	
	# 是否 改變
	var is_changed
	
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
