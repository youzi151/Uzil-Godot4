
# Variable ===================

var times_mgr = null

## 使用主體
var _user = null

## 是否鎖住
var _is_locked := false

## 預設狀態ID
var default_state_id := ""

## 當前狀態
var _current_state = null

## 下一個狀態
var _next_state = null

## 狀態列表 (不用Dictionary, 因為方便可以更改狀態的ID, 而且狀態通常不會太多個)
var _states := []

## 當 狀態改變 事件
var on_state_change = null

## 對應 時間實體
var times_inst_key = "_"

# GDScript ===================

func _init (__user = null) :
	self._user = __user
	
	# 當 狀態改變
	var Uzil = UREQ.access_g("Uzil", "Uzil")
	self.on_state_change = Uzil.Core.Evt.Inst.new()
	
	self.times_mgr = UREQ.access_g("Uzil", "times_mgr")
	


# Extends ====================

# Public =====================

## 設置 使用主體
func set_user (__user) :
	
	self._user = __user
	
	# 設置 所有狀態 使用主體
	for each in self._states :
		each.set_user(self._user)
		
	return self

## 新增 狀態
func add_state (state) :
	if self.get_state(state.id) != null : return self
	state.set_user(self._user)
	self._states.push_back(state)
	return self

## 建立 新 狀態
func new_state (script_name : String, prefer_state_id : String, data := {}) :
	
	var Uzil = UREQ.access_g("Uzil", "Uzil")
	
	var state = Uzil.Advance.StateMachine.State.new(script_name)
	
	var new_id = Uzil.Util.uniq_id.fix(prefer_state_id, func(next_id):
		for each in self._states :
			if each.id == next_id : return false
		return true
	)
	
	state.set_id(new_id).set_data(data)
	
	self.add_state(state)
	
	return state

## 取得 狀態
func get_state (state_id) :
	for each in self._states :
		if each.id == state_id :
			return each
	return null

## 開始 狀態機
func start () :
	
	self.set_user(self._user)
	
	for each in self._states :
		each.init() # 內含 是否已初始化檢查
	
	self.go_state(self.default_state_id)

## 更新
func process (_dt) :
	if not self._is_process() : return
	for each in self._states :
		each.process(_dt)

## 前往 狀態
func go_state (state_or_id, is_force := false) :
	
	var next_state = null
	
	# 類型
	var typ = typeof(state_or_id)
	match typ :
		# 字串
		TYPE_STRING : 
			for each in self._states :
				if each.id == state_or_id : 
					next_state = each
					break
		# 物件(狀態)
		TYPE_OBJECT :
			next_state = state_or_id
	
	# 若 缺少 指定狀態 則 返回
	if next_state == null : return
	# 若 當前狀態 已是 指定狀態 則 返回
	if self._current_state == next_state : return
	
	# 若 已鎖住狀態 且 非強制 則 設置 為 下一個狀態
	if self._is_locked and not is_force :
		self._next_state = next_state
		return
	
	# 前次狀態
	var last_state = self._current_state
	
	# 呼叫 前次狀態 當 離開狀態
	if last_state != null :
		last_state.on_exit()
	
	# 設為 當前狀態
	self._current_state = next_state
	
	self._current_state.on_enter()

## 鎖住
func lock () :
	self._is_locked = true

## 解鎖
func unlock () :
	self._is_locked = false
	# 若 下個狀態 存在
	if self._next_state :
		# 清除 下個狀態
		var state = self._next_state
		self._next_state = null
		# 前往狀態 強制
		self.go_state(state, true)

# Private ====================

## 是否可以推進
func _is_process () :
	if self.times_inst_key == null : return true
	return self.times_mgr.inst(self.times_inst_key).is_timing()
