
## InputPipe.Layer 輸入管道 管道層
##
## 持有 處理器, 事件, 訊號. 以及提供對應的操作介面.
## 

# Variable ===================

## 辨識
var id := ""

## 是否啟用
var is_active := true

## 所屬實體
var _inst = null

## 處理
var _id_to_handler := {}
var _handlers := []

## 虛擬代號 對應 訊號
var _vkey_to_msg := {}

## 虛擬代號 對應 事件
var _vkey_to_event := {}

# GDScript ===================

func _init (inst) :
	self._inst = inst

# Extends ====================

# Public =====================

## 啟用/關閉
func active (_is_active := true) :
	self.is_active = _is_active

# 訊號 #########

## 處理訊號
func handle_msg (input_msg) :
	
	for each in self._handlers :
		var copy_msg = input_msg.copy()
		
		# 把 輸入key 轉為 虛擬key
		each.handle_msg(copy_msg)
		
		# 紀錄 虛擬key
		self._vkey_to_msg[copy_msg.virtual_key] = copy_msg
		

## 以 虛擬key 取得 輸入訊號
func get_msg (vkey : int) :
	if self._vkey_to_msg.has(vkey) == false : return null
	return self._vkey_to_msg[vkey]
	

## 清除訊號
func clear_msgs () :
	self._vkey_to_msg.clear()
	

# 處理器 #######
	
## 取得 所有 處理器
func get_handlers () -> Array :
	return self._handlers

## 取得 處理器
func get_handler (handler_id : String) :
	if self._id_to_handler.has(handler_id) :
		return self._id_to_handler[handler_id] 
	else :
		return null

## 新增 處理器
func add_handler (handler) :
	
	if self._id_to_handler.has(handler.id) :
		self.del_handler(handler.id)
	
	self._id_to_handler[handler.id] = handler
	self._handlers.push_back(handler)

## 建立 並 新增 處理器
func new_handler (id, name_or_path, data) :
	var InputPipe = UREQ.acc("Uzil", "Basic.InputPipe")
	var handler = InputPipe.new_handler(id, name_or_path, data)
	self.add_handler(handler)
	return handler

## 移除 處理器
func del_handler (handler_id : String) :
	if not self._id_to_handler.has(handler_id) : return
	
	var exist = self._id_to_handler[handler_id]
	
	self._handlers.erase(exist)
	self._id_to_handler.erase(handler_id)
	

# 輸入 #########

## 取得 輸入訊號
func get_input (vkey : int) :
	if self._vkey_to_msg.has(vkey) : 
		return self._vkey_to_msg[vkey]
	else : 
		return null

## 新增 當 輸入 偵聽
func on_input (vkey : int, evtlistener_or_fn) :
	var Evt = null
	var evtlistener = evtlistener_or_fn
	if typeof(evtlistener_or_fn) == TYPE_CALLABLE :
		if Evt == null : Evt = UREQ.acc("Uzil", "Core.Evt")
		evtlistener = Evt.Listener.new().fn(evtlistener_or_fn)
	
	var evt
	if self._vkey_to_event.has(vkey) :
		evt = self._vkey_to_event[vkey]
	else :
		if Evt == null : Evt = UREQ.acc("Uzil", "Core.Evt")
		evt = Evt.Inst.new()
		self._vkey_to_event[vkey] = evt
	
	evt.on(evtlistener)
	
	return evtlistener

## 移除 當 輸入 偵聽
func off_input (vkey : String, evtlistener_or_tag) :
	if not self._vkey_to_event.has(vkey) : return
	self._vkey_to_event[vkey].del(evtlistener_or_tag)

## 呼叫 訊號
func call_input (input_msg) :
	if not input_msg.is_alive() : return
	if self._vkey_to_event.has(input_msg.virtual_key) == false : return
	self._vkey_to_event[input_msg.virtual_key].emit(input_msg)

## 呼叫 所有訊號
func call_all_input () :
	for each in self._vkey_to_msg.values() :
		self.call_input(each)

# Private ====================

