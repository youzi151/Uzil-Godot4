
## States.Runtime 狀態機 執行實體
## 
## 
## 

# Variable ===================

## 是否隨著實例推進
var is_process_with_inst := true

## 時間實例管理
var times_mgr = null
## 對應的 時間實例 key
var times_inst_key = "_"

## 所屬的狀態機
var states_inst = null

## 使用主體
var root = null

## 當前狀態
var current_state = null
## 當前轉場
var current_transition = null

## 是否鎖住
var _is_locked := false
## 下一個狀態
var _next_state = null

## 變數集
var _vars = null 
## 各狀態的變數集 (方便對應狀態使用)
var _state_to_vars := {}

## 是否 狀態轉換中
var _is_state_in_trans := false
## 是否 轉場忙碌中
var _is_transition_busy := false

## 是否除錯
var is_debug := false

## 是否已開始
var _is_start := false

## 當 狀態改變 事件
var on_state_changed = null

# GDScript ===================

func _init (states_inst = null) :
	self.states_inst = states_inst
	
	# 當 狀態改變
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	self.on_state_changed = Evt.Inst.new()
	
	self.times_mgr = UREQ.acc(&"Uzil:times_mgr")
	
	self._vars = UREQ.acc(&"Uzil:Core.Vars").Inst.new()


# Extends ====================

# Public =====================

## 開始 狀態機 (方便簡易啟動)
func start (root = null) :
	if self._is_start : return
	self._is_start = true
	if root != null :
		self.root = root
	self.setup()
	await self.go_state(self.states_inst.default_state_id)

## 建置
func setup () :
	# 每個狀態 呼叫 建置
	var args := [self, null]
	for each in self.states_inst.id_to_state.values() :
		args[1] = each
		await self.states_inst.handle_state(each.handlers, &"setup", args)

## 推進
func process (_dt: float) :
	if not self._is_process() : return
	# 當前狀態 呼叫 推進
	var args := [self, self.current_state, _dt]
	await self.states_inst.handle_state(self.current_state.handlers, &"process", args)
	# 檢查 並 轉場
	self.check_transitions()

## 前往 狀態
func go_state (id_or_state, is_force := false) :
	# 若 狀態轉換中 則 返回 (關係較大, 不得強制)
	if self._is_state_in_trans : return false
	
	# 若 當前轉場 存在 則
	if self.current_transition != null :
		# 若 非強制 則 返回
		if not is_force : return false
		# 解除轉場
		self.current_transition = null
		self._is_transition_busy = false
	
	var next_state_id := ""
	var next_state = null
	if typeof(id_or_state) == TYPE_STRING :
		next_state_id = id_or_state
		next_state = self.states_inst.get_state(id_or_state)
	else :
		next_state = id_or_state
	
	# 若 缺少 指定狀態 則 返回
	if next_state == null and not next_state_id.is_empty() : 
		G.print("[states_runtime] inst[%s] go_state state[%s] not found." % [next_state_id])
		return false
	
	# 若 已鎖住狀態 且 非強制 則 設置 為 下一個狀態
	if self._is_locked and not is_force :
		G.print("[states_runtime] inst[%s] set next_state : %s" % [next_state.id])
		self._next_state = next_state
		return false
	else :
		self._next_state = null
	
	# 若 當前狀態 已是 指定狀態 則 返回
	#if self.current_state == next_state : 
		#return true
	
	# 前次狀態
	var last_state = self.current_state
	
	# 設 狀態轉換中
	self._is_state_in_trans = true
	
	# 呼叫 前次狀態 當 離開狀態
	if last_state != null :
		await self.states_inst.handle_state(last_state.handlers, &"on_exit", [self, last_state])
	
	# 設為 當前狀態
	self.current_state = next_state
	
	if self.is_debug :
		G.print("[states_runtime] inst[%s] go state : %s" % [self.states_inst, self.current_state.id])
	
	if self.current_state != null :
		await self.states_inst.handle_state(self.current_state.handlers, &"on_enter", [self, self.current_state])
	
	# 解除 狀態轉換中
	self._is_state_in_trans = false
	
	self.on_state_changed.emit({
		"last" : last_state,
		"next" : next_state,
	})
	
	return true

## 檢查並轉場
func check_transitions () :
	# 若 鎖住 則 返回
	if self._is_locked : return
	# 若 轉場忙碌中 則 返回
	if self._is_transition_busy : return
	# 若 狀態轉換中 則 返回
	if self._is_state_in_trans : return
	# 若 當前狀態 為 空 則 返回
	if self.current_state == null : return
	
	# 設 忙碌中
	self._is_transition_busy = true
	
	# 下個轉場
	var nxt_state = null
	
	# 每個轉場
	for trans_id in self.current_state.transitions :
		var trans = self.states_inst.get_transition(trans_id)
		if trans == null : continue
		
		# 預設 通過
		var is_pass := true
		
		# 若 表達式 存在
		if trans.condition_exp != null :
			# 執行 並 取得 是否通過
			is_pass = (trans.condition_exp as Expression).execute([self, self._vars, self.current_state.data])
			# 若 不通過 則 繼續下個轉場
			if not is_pass : continue
		
		# 每個 條件
		for cond_id in trans.conditions :
			var cond = self.states_inst.get_condition(cond_id)
			if cond == null : 
				G.print("[states_runtime] check transition[%s] but condition[%s] not exist" % [trans_id, cond_id])
				break
			
			# 呼叫 條件 是否通過
			var handle_condition_ret = await self.states_inst.handle_condition(cond.handlers, &"is_pass", [self, trans, cond])
			if handle_condition_ret != null :
				is_pass = handle_condition_ret
			# 若 不通過 則 不繼續下個條件
			if not is_pass : break
		
		# 若 不通過 則 繼續下個轉場
		if not is_pass : continue
		
		# 若通過
		
		# 設置 當前轉場
		self.current_transition = trans
		# 呼叫 轉場 開始 (等候 每個Handler平行執行完畢)
		await self.states_inst.handle_transition(trans.handlers, &"start", [self, trans], {
			"parallel": true
		})
		# 若 當前轉場 已經不同 則 返回
		if self.current_transition != trans : return
		
		# 設置 下個狀態
		nxt_state = trans.to_state
		# 清空 當前轉場
		self.current_transition = null
		# 跳出 不繼續下個轉場
		break
	
	# 解除 轉場忙碌中
	self._is_transition_busy = false
	
	# 若 有指定下個狀態 則 前往
	if nxt_state != null :
		self.go_state(nxt_state)

## 取得 變數集
func vars (id_or_state = "") :
	var state_id := ""
	if typeof(id_or_state) == TYPE_STRING :
		state_id = id_or_state
	else :
		state_id = id_or_state.id
	
	if state_id == "" : return self._vars
	if self._state_to_vars.has(state_id) : return self._state_to_vars[state_id]
	
	if self.states_inst.get_state(state_id) == null : 
		G.error("[states_runtime] get runtime vars with non-exist state[%s]" % [state_id])
	
	var vars = UREQ.acc(&"Uzil:Core.Vars").Inst.new()
	self._state_to_vars[state_id] = vars
	return vars
	
## 鎖住
func lock () :
	self._is_locked = true

## 解鎖
func unlock () :
	self._is_locked = false
	# 若 下個狀態 存在
	if self._next_state != null :
		# 清除 下個狀態
		var state = self._next_state
		self._next_state = null
		# 前往狀態 強制
		self.go_state(state.id, true)

# Private ====================

## 是否可以推進
func _is_process () :
	if self.times_inst_key == null : return true
	# 依照 對應的時間實例 是否暫停來判斷
	return not self.times_mgr.inst(self.times_inst_key).is_paused()
