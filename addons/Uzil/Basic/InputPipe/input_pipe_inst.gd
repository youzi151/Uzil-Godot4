extends Node

## InputPipe.Inst 輸入管道 實體
##
## 輸入管道 主循環. [br]
## 蒐集 各層級 需要的 實際輸入 並透過 層級的 處理器 轉換為 要處理的訊號, 再 交由 各層級 發送事件 [br]
## 提供介面對不同階層進行操作
##
#
# 1.   Inst每幀會從每個Layer中的Handler取得要偵聽的srcKeyCode.
# 2.   Inst對每個要偵聽的srcKeyCode, 會產生Signal.
# 2.   Inst依序傳遞Msg給每個Layer, Layers再發Msg給所有Handler.
# 4-1. Handler會將Msg中實際的Input轉換為綁定/其他的對應Input.
# 4-2. 依序傳遞Msg給各個負責執行邏輯內容的onInputListener並夾帶參數.
# 5.   Listener可自行決定繼續傳遞
# 5-1. 透過 Ctrlr 的 stop 來停止傳遞給下一個Listener, 或使用 ignore 來標記要忽略掉之後那些tag的Listener.
# 5-2. 透過 Msg 的 stop 來停止傳給下一個Layer, 或使用 ignore 來標記要忽略掉之後那些tag的Layer.
# InputMsg(key17, key23) → 
#    1.1. InputLayer1 (Domain)
#       └ [Handler1] 把 key17 轉換/處理 成 兩倍值 添加成新key17 到 Layer
#       └ [Handler2] 把 key23 轉換/處理 成 key87 添加成新key87 到 Layer
#    2.1 [key17] → Listener1 ——→ Listener2
#        [key87] → Listener1 ——→ (ignore) ——→ Listener3 —x→ Listener4
#                                Listener2 
#        (可利用Event.Call時的ctrlr來進行中斷傳遞或設置忽略標籤)
#    1.2. InputLayer2 (Domain)                  
#       └ [Handler1] 把 key17 轉換/處理 成 兩倍值 添加成新key17 到 Layer
#       └ [Handler2] 把 key23 轉換/處理 成 key99 添加成新key99 到 Layer
#    2.1 [key17] → Listener1 ——→ Listener2
#        [key99] → Listener1 ——→ (ignore) ——→ Listener3 —x→ Listener4
#                                Listener2 
#        (可利用Event.Call時的ctrlr來進行中斷傳遞或設置忽略標籤)

var InputPipe

var Util

# Variable ===================

## 辨識
var id := ""

## 設定檔
var _setting = null

## 是否啟用
var is_active := true

## 層級
var _layers := []
## ID:層級 表
var _id_to_layer := {}

# GDScript ===================

func _init (setting) :
	self.InputPipe = UREQ.acc("Uzil", "Basic.InputPipe")
	self.Util = UREQ.acc("Uzil", "Util")
	
	self._setting = setting
	self._setting.set_inst(self)

func _process (_dt) :
	# 確保 輸入 刷新
	
	# 要偵測的真實key
	var to_listen_src_keys := []
	
	# 若 關閉 則 返回
	if not self.is_active : return
	
	# 每個層級
	for layer in self._layers :
		
		# 清空 訊號
		layer.clear_msgs()
		
		# 蒐集 要偵測的真實key
		for handler in layer.get_handlers() :
			
			for src_key in handler.src_keys :
				
				if not to_listen_src_keys.has(src_key) :
					to_listen_src_keys.push_back(src_key)
				
			
	
	# 每個 要偵測的真實key
	for src_key in to_listen_src_keys :
		
		# 產生 訊號 ####
		
		var input_msg = self._get_msg(src_key)
		
		# 若 查無訊號 則 忽略
		if input_msg == null :
			continue
			
		# 處理 訊號 ####
		
		# 交給 每個層級 處理
		for layer in self._layers :
			# 若 關閉中 則 忽略
			if not layer.is_active :
				continue
				
			# 處理訊號
			layer.handle_msg(input_msg)
			
		
	
	# 每個層級
	for layer in self._layers :
		
		# 若 關閉中 則 忽略
		if not layer.is_active : continue
			
		# 呼叫 所有訊號
		layer.call_all_input()
	

# Extends ====================

# Public =====================

## 取得 設定
func get_setting () :
	return self._setting

## 啟用/關閉
func active (_is_active := true) :
	self.is_active = _is_active

## 取得層級
func get_layer (layer_id : String) :
	var layer
	if self._id_to_layer.has(layer_id) :
		layer = self._id_to_layer[layer_id]
	else :
		layer = self.InputPipe.Layer.new(self, layer_id)
		self._id_to_layer[layer_id] = layer
		self._layers.push_back(layer)
	return layer

## 取得所有層級
func get_layers () -> Array :
	return self._layers.duplicate(false)

## 排序 層級
func sort_layers () :
	self._layers.sort_custom(func(a, b):
		return a.get_sort() < b.get_sort()
	)

## 移除 層級
func remove_layer (layer_id : String) :
	if not self._id_to_layer.has(layer_id) : return
	var layer = self._id_to_layer[layer_id]
	self._id_to_layer.erase(layer_id)
	self._layers.erase(layer)

## 清空
func clear () :
	self._layers.clear()
	self._id_to_layer.clear()

# 轉接 Layer ======
#
### 新增 處理器
#func add_handler (layer_id, input_handler) :
#	var layer = self.get_layer(layer_id)
#	layer.add_handler(input_handler)
#
### 新增 處理器
#func del_handler (layer_id, handler_id) :
#	var layer = self.get_layer(layer_id)
#	layer.del_handler(handler_id)
#
### 新增 處理器
#func get_handlers (handler_id) :
#	var handlers = []
#
#	for layer in self._layers :
#
#		for handler in layer.get_handlers() :
#
#			if handler.id != handler_id : continue
#
#			if not handlers.has(handler) :
#				handlers.push_back(handler)
#
#
#	return handlers
#
### 查詢
#func get_input (layer_id, vkey) :
#	var layer = self.get_layer(layer_id)
#	return layer.get_input(vkey)
#
### 註冊 當 輸入
#func on_input (layer_id, vkey, evt_listener_or_fn) :
#	var layer = self.get_layer(layer_id)
#	layer.on_input(vkey, evt_listener_or_fn)
#
### 註銷 當 輸入
#func off_input (layer_id, vkey, evt_listener_or_tag) :
#	var layer = self.get_layer(layer_id)
#	layer.off_input(vkey, evt_listener_or_tag)
#
### 停止輸入 
## 以最終的虛擬KeyCode, 向該層級取得訊號後執行停止, 追溯到源訊號將實際KeyCode關閉
#func stop_input (layer_id, vkey, is_stop_whole_steam) :
#	var layer = self.get_layer(layer_id)
#	var input_msg = layer.get_msg(vkey)
#	if input_msg == null : return
#	input_msg.stop(is_stop_whole_steam)


# Private ====================

## 取得輸入 信號
func _get_msg (src_key : int) :
	# 建立訊號
	var input_msg = self.InputPipe.Msg.new().init(src_key)
	
	# 取得 訊號 值
	input_msg.val = self.Util.input.get_input(src_key)
	
	return input_msg
