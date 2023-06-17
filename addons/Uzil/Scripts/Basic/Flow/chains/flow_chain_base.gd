
## Flow.Chain_Base 流程控制 節點鏈 基本
##
## 作為 執行內容 與 條件 的 容器
##

var Flow

# Variable ===================

## 殼
var _shell

## 事件
var _events := []

## 條件
var _gates := []

## 是否在條件滿足時，自動結束此節點
var is_exit_on_complete := true


# GDScript ===================

func _init () :
	self.Flow = UREQ.access_g("Uzil", "Basic.Flow")

# Interface ==================

## 設置 殼
func _set_shell (shell) :
	self._shell = shell

## 讀取 紀錄
func _load_memo (_memo : Dictionary) :
	
	if _memo.has("events") : 
		self._events = _memo["events"]
	
	if _memo.has("gates") : 
		self._gates = _memo["gates"]
	
	if _memo.has("is_exit_on_complete") : 
		self.is_exit_on_complete = _memo["is_exit_on_complete"]

## 匯出 紀錄
func _to_memo (_memo, _args) :
	
	_memo["events"] = self._events.duplicate()
	_memo["gates"] = self._gates.duplicate()
	_memo["is_exit_on_complete"] = self.is_exit_on_complete
	
	return _memo

## 當 初始化
func _on_init (_init_data) :
	self._load_memo(_init_data)

## 當 進入
func _on_enter () :
	var inst = self._shell._get_inst()
	
	for each in self._events :
		var evt = inst.get_event(each)
		if evt != null :
			evt.enter()
			
	for each in self._gates :
		var gate = inst.get_gate(each)
		if gate != null :
			gate.enter()

## 當 每幀更新
func _on_process (_dt) :
	self.check_if_complete()

## 當 離開
func _on_exit () :
	
	var inst = self._shell._get_inst()
	
	for each in self._events :
		var evt = inst.get_event(each)
		if evt != null :
			evt.exit()
	

# Public =====================

## 新增 事件
func add_event (__id : String) :
	self._events.push_back(__id)

## 移除 事件
func del_event (__id : String) :
	self._events.erase(__id)

## 新增 條件
func add_gate (__id : String) :
	self._gates.push_back(__id)

## 移除 條件
func del_gate (__id : String) :
	self._gates.erase(__id)
	

## 檢查是否完成條件
func check_if_complete () :
	if self._shell._state != self.Flow.ActiveState.ACTIVE : 
		return
		
	if self._shell.get_nexts().size() == 0 :
		return
		
	var is_complete = true
	
	var inst = self._shell._get_inst()
	for each in self._gates :
		var gate = inst.get_gate(each)
		if not gate.is_complete() :
			is_complete = false
			break
	
	if is_complete :
		self.on_gate_complete()
		

func on_gate_complete () :
	
	self._shell._state = self.Flow.ActiveState.COMPLETE
#	print("self._shell._state %s" % self._shell._state)
	
	# 若 當完成時 結束
	if self.is_exit_on_complete :
		self._shell.exit()
	
	# 啟動後續節點
	var inst = self._shell._get_inst()
	for each in self._shell.get_nexts() :
		var chain = inst.get_chain(each)
		
		if chain == null : continue
		
		# 防止循環
#		if chain == self : 
#			UREQ.access_g("Uzil", "invoker").inst("_uzil").once(func() :
#				chain.enter()
#			)
#			continue
		
		chain.enter()
	

# Private ====================

