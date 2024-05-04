extends Node

## UINav.Chain 用戶介面導航 鏈節點 管理
##
## 代表UI單位, 持有 自己的資料 與 指定處理器.
## 

# Variable ===================

## 辨識
var id : String = ""

## 處理器
var _handler : String = ""

## 鄰近鏈節點:指定處理器 表 (若沒有指定處理器 則 會以該鄰近鏈節點的自身的處理器為準)
var _neighbor_to_handler := {}

## 資料
var data := {}

## 是否已初始化
var _is_inited := false

## 是否啟用
var _is_active := false

## 所屬
var _inst_id : String = ""
var _inst_cache = null

# GDScript ===================

func _init (__handler) :
	self._handler = __handler

# Extends ====================

# Public =====================

## 初始化
func init (inst_id: String, data = null) :
	if self._is_inited : return
	
	self._inst_id = inst_id
	self._inst_cache = null
	
	# 若 處理器 存在
	var handler = self.get_handler()
	if handler != null :
		if handler.has_method("init") :
			handler.init(self)
	
	# 若 資料存在 則 設置資料
	if data != null :
		self.set_data(data)
		
	self._is_inited = true

## 更新
func process (_dt) :
	# 未啟用 則 返回
	if not self._is_active : return
	var handler = self.get_handler()
	if handler != null :
		if handler.has_method("process") :
			handler.process(self, _dt)

## 設置 ID
func set_id (_id: String) :
	self.id = _id
	return self

## 添加 鄰近鏈節點
func add_neighbors (_neighbors) :
	var typ = typeof(_neighbors)
	
	match typ :
		
		TYPE_ARRAY :
			for name in _neighbors :
				if not self._neighbor_to_handler.has(name) :
					self._neighbor_to_handler[name] = ""
		
		TYPE_DICTIONARY :
			for name in _neighbors :
				if not self._neighbor_to_handler.has(name) :
					self._neighbor_to_handler[name] = _neighbors[name]
		

## 移除 鄰近鏈節點
func del_neighbors (_neighbors) :
	for name in _neighbors :
		if self.neighbor_to_relationship.has(name) :
			self.neighbor_to_relationship.erase(name)

## 取得 所有 鄰近鏈節點
func get_neighbor_chains () -> Array :
	
	var inst = self._get_inst()
	
	var res := []
	for each in self._neighbor_to_handler :
		var neighborChain = inst.get_chain(each)
		res.push_back(neighborChain)
	
	return res

## 取得 鄰近鏈節點 指定處理器
func get_neighbor_handler (_neighbor) :
	if _neighbor == null :
		return self._neighbor_to_handler.duplicate()
		
	if self._neighbor_to_handler.has(_neighbor) :
		return self._neighbor_to_handler[_neighbor]
		
	return null

## 設置 處理器
func set_data (data) :
	var handler = self.get_handler()
	if handler == null : return self
	if handler.has_method("set_data") :
		handler.set_data(self, data)
	else :
		self.data = data
	return self

## 當 鏈節點 進入
func on_enter () :
	# 設置 啟用
	self._is_active = true
	
	# 呼叫 所屬處理器
	var handler = self.get_handler()
	if handler == null : return self
	if handler.has_method("on_enter") :
		handler.on_enter(self)

## 當 鏈節點 離開
func on_exit () :
	# 設置 非啟用
	self._is_active = false
	
	# 呼叫 所屬處理器
	var handler = self.get_handler()
	if handler == null : return self
	if handler.has_method("on_exit") :
		handler.on_exit(self)

## 取得 處理器
func get_handler () :
	var UINav = UREQ.acc("Uzil", "Advance.UINav")
	return UINav.get_handler(self._handler)

## 取得 處理器 類型 (提供別的鏈結點進行比較)
func get_handler_name () :
	return self._handler

## 取得 處理器 腳本 (提供別的鏈結點進行比較)
func get_handler_script () :
	var handler = self.get_handler()
	if handler == null : return null
	return handler.get_script()

## 取得 鄰近值 (提供別的鏈結點進行比較)
func get_near_val (key: String, req_data := {}) :
	# 呼叫 所屬類型
	var handler = self.get_handler()
	if handler == null : return null
	if handler.has_method("get_near_val") :
		return handler.get_near_val(self, key, req_data)
	else :
		return null
	
## 取得 最近的 鄰近 鏈節點
func get_nearest_neighbor (req_data := {}) :
	# 呼叫 所屬類型
	var handler = self.get_handler()
	if handler == null : return null
	if handler.has_method("get_nearest_neighbor") :
		return handler.get_nearest_neighbor(self, req_data)
	else :
		return null

# Private ====================

## 取得所屬
func _get_inst () :
	if self._inst_cache == null :
		var ui_nav_mgr = UREQ.acc("Uzil", "ui_nav_mgr")
		self._inst_cache = ui_nav_mgr.inst(self._inst_id)
	return self._inst_cache

