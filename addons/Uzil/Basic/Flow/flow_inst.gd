extends Node

## Flow.Inst 流程控制 實體
##
## 對 節點鏈, 條件, 事件 的 建立/持有/管理/紀錄.
## 

var Flow 

# Variable ===================

## 關鍵字
var _key := "default"

## 時間實體
var _times_inst = null

## 節點
var _id_to_chain := {}

## 事件
var _id_to_event := {}

## 條件
var _id_to_gate := {}


# GDScript ===================

func _init (_dont_set_in_scene) :
	self.Flow = UREQ.acc("Uzil", "Flow")
	
	var times = UREQ.acc("Uzil", "times_mgr")
	self._times_inst = times.inst(self._key)

func _process (_dt) :
	var times_dt : float = self._times_inst.dt_sec()
	
	for each in self._id_to_gate.values() :
		each.process(times_dt)
	
	for each in self._id_to_chain.values() :
		each.process(times_dt)
	
	for each in self._id_to_event.values() :
		each.process(times_dt)

# Interface ==================

## 讀取 紀錄
func load_memo (_memo: Dictionary) :
	
	if _memo.has("chains") :
		var _chains = _memo["chains"]
		var new_datas = _chains.duplicate()
		# 每個 現有的
		for key in self._id_to_chain :
			# 若 在 新資料 中
			if new_datas.has(key) :
				# 讀取 進 舊 的
				var new_data = new_datas[key]
				self.get_chain(key).load_memo(new_data)
				# 從新的中移除
				new_datas.erase(key)
			# 若 不在 新的資料 中
			else :
				# 移除
				self.del_chain(key)
				
		# 每個 新資料
		for key in new_datas :
			var each = _chains[key].duplicate()
			each["id"] = key
			self.new_chain(each, true)
			
	if _memo.has("events") :
		var _events = _memo["events"]
		var new_datas = _events.duplicate()
		# 每個 現有的
		for key in self._id_to_event :
			# 若 在 新資料 中
			if new_datas.has(key) :
				# 讀取 進 舊 的
				var new_data = new_datas[key]
				self.get_event(key).load_memo(new_data)
				# 從新的中移除
				new_datas.erase(key)
			# 若 不在 新的資料 中
			else :
				# 移除
				self.del_event(key)
				
		# 每個 新資料
		for key in new_datas :
			var each = _events[key].duplicate()
			each["id"] = key
			self.new_event(each, true)
			
	if _memo.has("gates") :
		var _gates = _memo["gates"]
		var new_datas = _gates.duplicate()
		# 每個 現有的
		for key in self._id_to_gate :
			# 若 在 新資料 中
			if new_datas.has(key) :
				# 讀取 進 舊 的
				var new_data = new_datas[key]
				self.get_gate(key).load_memo(new_data)
				# 從新的中移除
				new_datas.erase(key)
			# 若 不在 新的資料 中
			else :
				# 移除
				self.del_gate(key)
				
		# 每個 新資料
		for key in new_datas :
			var each = _gates[key].duplicate()
			each["id"] = key
			self.new_gate(each, true)
			

## 匯出 紀錄
func to_memo (_args = null) :
	var memo := {}
	
	var chains := {}
	for key in self._id_to_chain.keys() :
		chains[key] = self._id_to_chain[key].to_memo()
	memo["chains"] = chains
	
	var events := {}
	for key in self._id_to_event.keys() :
		events[key] = self._id_to_event[key].to_memo({})
	memo["events"] = events
	
	var gates := {}
	for key in self._id_to_gate.keys() :
		gates[key] = self._id_to_gate[key].to_memo({})
	memo["gates"] = gates
	
	return memo


# Public =====================

## 初始化
func init (key: String) :
	self._key = key
	return self

## 取得 節點
func get_chain (id: String) :
	if self._id_to_chain.has(id) :
		return self._id_to_chain[id]
	else :
		return null

## 取得 事件
func get_event (id: String) :
	if self._id_to_event.has(id) :
		return self._id_to_event[id]
	else :
		return null

## 取得 條件
func get_gate (id: String) :
	if self._id_to_gate.has(id) :
		return self._id_to_gate[id]
	else :
		return null

## 重新命名 節點
func rename_chain (id: String, new_id: String) :
	
	if not self._id_to_chain.has(id) : return
		
	new_id = self._get_fix_id(new_id, self._id_to_chain)
	var exist = self._id_to_chain[id]
	self._id_to_chain[new_id] = exist
	self._id_to_chain.erase(id)
	exist._id = new_id
	return new_id

## 重新命名 節點
func rename_event (id: String, new_id: String) :
	
	if not self._id_to_event.has(id) : return
		
	var exist = self._id_to_event[id]
	new_id = self._get_fix_id(new_id, self._id_to_event)
	self._id_to_event[new_id] = exist
	self._id_to_event.erase(id)
	exist._id = new_id
	return new_id

## 重新命名 節點
func rename_gate (id: String, new_id: String) :
	
	if not self._id_to_gate.has(id) : return
	
	var exist = self._id_to_gate[id]
	new_id = self._get_fix_id(new_id, self._id_to_gate)
	self._id_to_gate[new_id] = exist
	self._id_to_gate.erase(id)
	exist._id = new_id
	return new_id

## 創建 節點
func new_chain (data: Dictionary, is_overwrite := false) :
	
	# 試著 取得腳本
	var script = null
	if data.has("script") :
		script = self.Flow.get_chain_script(data["script"])
		
	if script == null :
		script = self.Flow.get_chain_script("base")
	
	# 若 無法取得 則 返回 空
	if script == null : return null
	
	# 建立
	var new_one = self.Flow.Chain.new(script.new())
	# 初始化
	new_one.init(self._key, data)
	new_one.load_memo(data)
	
	# 加入
	self._add_chain(new_one, is_overwrite)
	
	return new_one

## 創建 節點
func new_event (data: Dictionary, is_overwrite := false) :
	
	# 試著 取得腳本
	var script = null
	if data.has("script") :
		script = self.Flow.get_event_script(data["script"])
	
	# 若 無法取得 則 返回 空
	if script == null : return null
	
	# 建立
	var new_one = self.Flow.Event.new(script.new())
	# 初始化
	new_one.init(self._key, data)
	new_one.load_memo(data)
	
	# 加入
	self._add_event(new_one, is_overwrite)
	
	return new_one

## 創建 條件
func new_gate (data: Dictionary, is_overwrite := false) :
	
	# 試著 取得腳本
	var script = null
	if data.has("script") :
		script = self.Flow.get_gate_script(data["script"])
	
	# 若 無法取得 則 返回 空
	if script == null : return null
	
	# 建立
	var new_one = self.Flow.Gate.new(script.new())
	# 初始化
	new_one.init(self._key, data)
	new_one.load_memo(data)
	
	# 加入
	self._add_gate(new_one, is_overwrite)
	
	return new_one

## 移除 節點
func del_chain (id: String) :
	if not self._id_to_chain.has(id) : return
	var to_rm = self._id_to_chain[id]
	self._id_to_chain.erase(id)
	to_rm.destroy()

## 移除 事件
func del_event (id: String) :
	if not self._id_to_event.has(id) : return
	var to_rm = self._id_to_event[id]
	self._id_to_event.erase(id)
	to_rm.destroy()

# 移除 節點
func del_gate (id: String) :
	if not self._id_to_gate.has(id) : return
	var to_rm = self._id_to_gate[id]
	self._id_to_gate.erase(id)
	to_rm.destroy()

## 清空
func clear () :
	var keys
	var values
	
	keys = self._id_to_chain.keys()
	values = self._id_to_chain.values()
	for idx in range(keys.size()) :
		self._id_to_chain.erase(keys[idx])
		values[idx].destroy()
	
	keys = self._id_to_event.keys()
	values = self._id_to_event.values()
	for idx in range(keys.size()) :
		self._id_to_event.erase(keys[idx])
		values[idx].destroy()
	
	keys = self._id_to_gate.keys()
	values = self._id_to_gate.values()
	for idx in range(keys.size()) :
		self._id_to_gate.erase(keys[idx])
		values[idx].destroy()

## 新增 節點
func _add_chain (chain, is_overwrite := false) :
	
	var id = chain.id()
	
	# 若 ID	未設定 則 自動取
	if id == null or id == "":
		id = self._get_fix_id("_chain_", self._id_to_chain)
		chain._id = id
	
	# 若 已存在相同ID
	elif self._id_to_chain.has(id) :
		# 若非覆寫 則 返回
		if not is_overwrite :
			return
		
		# 移除現有
		self.del_chain(id)
	
	# 寫入
	self._id_to_chain[id] = chain

## 新增 節點
func _add_event (evt, is_overwrite := false) :
	
	var id = evt.id()

	# 若 ID	未設定 則 自動取
	if id == null or id == "":
		id = self._get_fix_id("_event_", self._id_to_event)
		evt._id = id
	
	# 若 已存在相同ID
	elif self._id_to_event.has(id) :
		# 若非覆寫 則 返回
		if not is_overwrite :
			return
		
		# 移除現有
		self.del_event(id)
	
	# 寫入
	self._id_to_event[id] = evt

## 新增 節點
func _add_gate (gate, is_overwrite := false) :
	
	var id = gate.id()

	# 若 ID	未設定 則 自動取
	if id == null or id == "":
		id = self._get_fix_id("_gate_", self._id_to_gate)
		gate._id = id
	
	# 若 已存在相同ID
	elif self._id_to_gate.has(id) :
		# 若非覆寫 則 返回
		if not is_overwrite :
			return
		
		# 移除現有
		self.del_gate(id)
	
	# 寫入
	self._id_to_gate[id] = gate

func _get_fix_id (perfer_id: String, dict: Dictionary) :
	var idx = 0
	var id = "%s" % perfer_id
	while dict.has(id) :
		idx += 1
		id = "%s%s" % [perfer_id, idx]
	return id
