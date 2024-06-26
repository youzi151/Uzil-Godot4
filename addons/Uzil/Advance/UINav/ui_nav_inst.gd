extends Node

## UINav.Inst 用戶介面導航 實體
##
## 持有各鏈節點, 並接收呼叫資料來改變當前所在的UI單位.
## 

# Variable ===================

## 實體鍵
var _inst_key : String = ""

## 當前鏈節點
var _current_chain = null

## 鏈節點列表 (不用Dictionary, 用列表方便可以更改ID)
var _chains := []

## 閒置鏈節點ID (若沒有處於任何鏈節點中(當前鏈節點不存在)時 以此為當前鏈節點)
var _idle_chain_id : String = ""

## 當 當前鏈節點改變 事件
var on_chain_change = null


# GDScript ===================

func _init (__inst_key: String) :
	
	self._inst_key = __inst_key
	
	# 當 當前鏈節點改變
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	self.on_chain_change = Evt.Inst.new()
	

# Extends ====================

# Public =====================

## 推進
func process (_dt) :
	for each in self._chains :
		each.process(_dt)

## 取得 當前鏈節點
func get_current () :
	return self._current_chain

## 設置 閒置 鏈節點
func set_idle_chain (chain_id: String) :
	self._idle_chain_id = chain_id

## 取得 鏈節點
func get_chain (chain_id) :
	for each in self._chains :
		if each.id == chain_id :
			return each
	return null

## 新增 鏈節點
func add_chain (chain) :
	if self.get_chain(chain.id) != null : return self
	self._chains.push_back(chain)
	return self

## 建立 新 鏈節點
func new_chain (prefer_chain_id: String, script_name: String, data := {}) :
	
	var UINav = UREQ.acc(&"Uzil:Advance.UINav")
	var Util = UREQ.acc(&"Uzil:Util")
	
	var chain = UINav.Chain.new(script_name)
	
	var new_id = Util.uniq_id.fix(prefer_chain_id, func(next_id):
		for each in self._chains :
			print("%s == %s = %s" % [each.id, next_id, each.id == next_id])
			if each.id == next_id : return false
		return true
	)
	
	chain.set_id(new_id)
	
	chain.init(_inst_key, data)
	
	self.add_chain(chain)
	
	return chain

## 移除 鏈節點
func del_chain (chain_id: String) :
	var exist = self.get_chain(chain_id)
	if exist == null : return
	self._chains.erase(exist)

## 清空
func clear () :
	self._current_chain = null
	self._chains.clear()
	self._idle_chain_id = ""
	self.on_chain_change.clear()

## 直接前往 鏈節點
func go_chain (chain_or_id) :
	
	var next_chain = null
	
	# 類型
	var typ = typeof(chain_or_id)
	match typ :
		# 字串
		TYPE_STRING : 
			for each in self._chains :
				if each.id == chain_or_id : 
					next_chain = each
		# 物件(鏈節點)
		TYPE_OBJECT :
			next_chain = chain_or_id
	
	# 若 當前鏈節點 已是 指定鏈節點 則 返回
	if self._current_chain == next_chain : return
	
	# 前次鏈節點
	var last_chain = self._current_chain
	
	if last_chain == null :
		last_chain = self.get_chain(self._idle_chain_id)
	
	# 若 前次鏈節點 存在 則 呼叫 當 離開鏈節點
	if last_chain != null :
		last_chain.on_exit()
	
	# 設為 當前鏈節點
	self._current_chain = next_chain
	
	# 若 鏈節點 存在 則 呼叫 當 啟用
	if self._current_chain != null :
		self._current_chain.on_enter()
	
	# 呼叫事件
	self.on_chain_change.emit({
		"last" : last_chain,
		"next" : next_chain,
	})

## 前往 導航
func go_nav (req_data := {}) :
	
	# 當前 鏈節點
	var curr_chain = self._current_chain
	
	if curr_chain == null :
		curr_chain = self.get_chain(self._idle_chain_id)
	
	if curr_chain == null : 
		return
	
	# 取得 最近的鄰近鏈節點
	var nearest = curr_chain.get_nearest_neighbor(req_data)
	if nearest == null : return
	
	self.go_chain(nearest)

# Private ====================

