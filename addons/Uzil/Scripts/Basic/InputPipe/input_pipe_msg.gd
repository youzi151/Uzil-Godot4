
## InputPipe.Msg 輸入管道 訊號
##
## 代表 一個 由 實際輸入 到 虛擬輸入 的 輸入相關訊號資料.
## 

# Variable ===================

## 辨識
var id := ""

## 是否啟用
var _is_alive := true

## 實際 key
var real_key := 0

## 虛擬 key
var virtual_key := 0

## 來源訊號
var src_msg = null

## 值
var val = null

# GDScript ===================

# Extends ====================

# Public =====================

## 初始化
func init (key : int) :
	self.real_key = key
	self.virtual_key = key
	return self

## 是否有效
func is_alive (is_check_stream := true) -> bool :
	# 若 自身 已關閉 則 視為 無效
	if self._is_alive == false : return false
	
	# 若 不檢查 整串
	if not is_check_stream :
		# 直接 返回 有效
		return true
		
	else :
	
		# 檢查 整條 訊號鏈
		var curr = self
		var trytime := 100
		while curr.src_msg != null and trytime > 0 :
			curr = curr.src_msg
		
			if curr._is_alive == false :
				return false
				
			trytime -= 1
		
		return true

## 終止
func stop (is_stop_whole_stream := true) :
	self._is_alive = false
	
	# 若 為 停止 整串 訊號鏈
	if is_stop_whole_stream :
		var curr = self
		var trytime = 100
		while curr.src_msg != null and trytime > 0 :
			curr = curr.src_msg
			
			curr._is_alive = false
			
			trytime -= 1

## 取得 副本
func copy () :
	var new_one = self.get_script().new()
	new_one._is_alive = self._is_alive
	
	new_one.real_key = self.real_key
	new_one.virtual_key = self.virtual_key
	new_one.val = self.val
	
	new_one.src_msg = self
	
	return new_one
