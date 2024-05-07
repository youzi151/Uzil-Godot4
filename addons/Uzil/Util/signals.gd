
## Signal相關
##
## 處理 Signal 的 相關事務
## 

## 等候控制器
## 
## == 使用範例 == [br]
## # 建立 並 傳入要註冊的原訊號
## var wait_ctrlr = signals.wait_ctrlr(some_node.tree_entered)
## # 等候訊號觸發 (若已觸發過 則 直接通過)
## await wait_ctrlr.until_emit()
## # 可選 手動關閉 對 原訊號移除註冊
## wait_ctrlr.close()
## # 釋放 會因為計數為0銷毀 並 自動對原訊號移除註冊
## wait_ctrlr = null
## 
class WaitCtrlr :
	## 已連接的訊號
	var signal_connected : Signal
	## 連接到訊號的callable (用於斷開連接)
	var callable_connected : Callable
	
	## 是否已經觸發
	var is_emited : bool = false
	## 當 觸發 訊號
	signal on_emit
	
	## 建構
	func _init (_signal: Signal) :
		# 設置 訊號
		self.signal_connected = _signal
		# 開始等候訊號
		self._start_wait()
		# 取 最後一個連接 為 已連接callable
		self.callable_connected = self.signal_connected.get_connections().back()[&"callable"]
	func _start_wait () :
		# 等候訊號
		await self.signal_connected
		# 觸發 已完成
		self.is_emited = true
		self.on_emit.emit()
	
	## 解構
	func _notification (what: int) -> void :
		if what != NOTIFICATION_PREDELETE : return
		# 移除 已連接
		if self.signal_connected.is_connected(self.callable_connected) :
			self.signal_connected.disconnect(self.callable_connected)
	
	## 直到觸發
	func until_emit () :
		if not self.is_emited : await self.on_emit
	
	## 手動關閉 (或者可從計數歸零自動解構時斷開連接)
	func close () :
		if self.signal_connected.is_connected(self.callable_connected) :
			self.signal_connected.disconnect(self.callable_connected)


## 建立 等候控制器
func wait_ctrlr (_signal: Signal) :
	return WaitCtrlr.new(_signal)


