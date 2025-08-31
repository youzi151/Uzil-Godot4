
# Variable ===================

var States
var Handlers

## 狀態列表
var id_to_state := {}
var id_to_transition := {}
var id_to_condition := {}

## 狀態,轉場,條件 處理器
var handlers_state = null
var handlers_transition = null
var handlers_condition = null

## 預設狀態ID
var default_state_id := ""

var default_call_opts := {
	"is_stop_on_handled": false,
}

var runtimes := []

# GDScript ===================

func _init () :
	self.States = UREQ.acc(&"Uzil:Advance.States")
	self.Handlers = UREQ.acc(&"Uzil:Basic.Handlers")
	
	self.handlers_state = self.Handlers.Inst.new(self.Handlers)
	self.handlers_state.get_handler_script_fn = self.States.get_handler_state
	self.handlers_transition = self.Handlers.Inst.new(self.Handlers)
	self.handlers_transition.get_handler_script_fn = self.States.get_handler_transition
	self.handlers_condition = self.Handlers.Inst.new(self.Handlers)
	self.handlers_condition.get_handler_script_fn = self.States.get_handler_condition

# Extends ====================

# Public =====================

## 推進更新
func process (_dt: float) :
	for each in self.runtimes :
		if each.is_process_with_inst :
			each.process(_dt)

## 開始 狀態機
func new_runtime () :
	var runtime = self.States.Runtime.new(self)
	self.runtimes.push_back(runtime)
	return runtime

## 取得 狀態
func get_state (id: String) :
	if not self.id_to_state.has(id) : return null
	return self.id_to_state[id]

## 建立 狀態
func new_state (prefer_id: String, dict := {}) :
	var States = UREQ.acc(&"Uzil:Advance.States")
	var Util = UREQ.acc(&"Uzil:Util")
	
	var state = States.State.new()
	
	# 避免重複ID
	var new_id = Util.uniq_id.fix(prefer_id, func(next_id):
		return not self.id_to_state.has(next_id)
	)
	state.id = new_id
	
	# 設置資料
	state.set_dict(dict)
	
	# 新增至列表
	self.add_state(state)
	
	return state

## 新增 狀態
func add_state (state) :
	# 移除相同ID者
	self.del_state(state.id)
	# 加入
	self.id_to_state[state.id] = state
	return self

## 移除 狀態
func del_state (id: String) :
	if not self.id_to_state.has(id) : return
	self.id_to_state.erase(id)


## 取得 狀態
func get_transition (id: String) :
	if not self.id_to_transition.has(id) : return null
	return self.id_to_transition[id]

## 建立 轉場
func new_transition (prefer_id: String, dict := {}) :
	var States = UREQ.acc(&"Uzil:Advance.States")
	var Util = UREQ.acc(&"Uzil:Util")
	
	var transition = States.Transition.new()
	
	# 避免重複ID
	var new_id = Util.uniq_id.fix(prefer_id, func(next_id):
		return not self.id_to_transition.has(next_id)
	)
	transition.id = new_id
	
	# 設置資料
	transition.set_dict(dict)
	
	# 新增至列表
	self.add_transition(transition)
	
	return transition

## 新增 轉場
func add_transition (transition) :
	# 移除相同ID者
	self.del_transition(transition.id)
	# 加入
	self.id_to_transition[transition.id] = transition
	return self

## 移除 轉場
func del_transition (id: String) :
	if not self.id_to_transition.has(id) : return
	self.id_to_transition.erase(id)


## 取得 條件
func get_condition (id: String) :
	if not self.id_to_condition.has(id) : return null
	return self.id_to_condition[id]

## 建立 條件
func new_condition (prefer_id: String, dict := {}) :
	var States = UREQ.acc(&"Uzil:Advance.States")
	var Util = UREQ.acc(&"Uzil:Util")
	
	var condition = States.Condition.new()
	
	# 避免重複ID
	var new_id = Util.uniq_id.fix(prefer_id, func(next_id):
		return not self.id_to_condition.has(next_id)
	)
	condition.id = new_id
	
	# 設置資料
	condition.set_dict(dict)
	
	# 新增至列表
	self.add_condition(condition)
	
	return condition

## 新增 條件
func add_condition (condition) :
	# 移除相同ID者
	self.del_condition(condition.id)
	# 加入
	self.id_to_condition[condition.id] = condition
	return self

## 移除 條件
func del_condition (id: String) :
	if not self.id_to_condition.has(id) : return
	self.id_to_condition.erase(id)


## 處理 狀態
func handle_state (handler_ids: Array, method_name: StringName, args: Array) :
	await self.handlers_state.call_method(handler_ids, method_name, args, self.default_call_opts)

## 處理 轉場
func handle_transition (handler_ids: Array, method_name: StringName, args: Array, opts := {}) :
	if not opts.is_empty() : opts = self.default_call_opts.merged(opts, true)
	else : opts = self.default_call_opts
	await self.handlers_transition.call_method(handler_ids, method_name, args, opts)

## 處理 條件
func handle_condition (handler_ids: Array, method_name: StringName, args: Array) :
	var ctrlr = await self.handlers_condition.call_method(handler_ids, method_name, args, self.default_call_opts)
	return ctrlr.result

# Private ====================
