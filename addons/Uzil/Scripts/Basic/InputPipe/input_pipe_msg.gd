
## InputPipe.Msg 輸入管道 訊號
##
## 代表 一個 由 實際輸入 到 虛擬輸入 的 輸入相關訊號資料.
## 

# Variable ===================

## 辨識
var id := ""

## 是否啟用
var _is_alive := true

## 忽略標記
var _ignore_tags : Array[String] = []

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
func is_alive (is_src_streamed := true) -> bool :
	# 若 自身 已關閉 則 視為 無效
	if self._is_alive == false : return false
	
	# 若 要檢查 源頭
	if is_src_streamed :
		if self.src_msg != null :
			return self.src_msg.is_alive(true)
	
	# 直接 返回 有效
	return true

## 取得 忽略標籤
func get_ignores (is_src_streamed := true) -> Array[String] :
	# 若 要 連同 源頭
	if is_src_streamed : 
		if self.src_msg != null :
			var ignores = self.src_msg.get_ignores().duplicate()
			for each in self._ignore_tags :
				if not ignores.has(each) :
					ignores.push_back(each)
			return ignores
	
	return self._ignore_tags

## 是否忽略
func is_ignores (tags : Array[String], is_src_streamed := true) -> bool :
	var self_ignores = self.get_ignores(is_src_streamed)
	for each in tags :
		if self_ignores.has(each) : return true
	return false

## 忽略
func ignore (tag : String, is_src_streamed := true) :
	if not self._ignore_tags.has(tag) :
		self._ignore_tags.push_back(tag)
		
	# 若 要 連同 源頭
	if is_src_streamed :
		if self.src_msg != null :
			return self.src_msg.ignore(tag, true)

## 終止
func stop (is_src_streamed := true) :
	
	self._is_alive = false
	
	# 若 要 連同 源頭
	if is_src_streamed :
		if self.src_msg != null :
			return self.src_msg.stop(true)

## 取得 副本
func copy () :
	var new_one = self.get_script().new()
	new_one._is_alive = self._is_alive
	
	new_one.real_key = self.real_key
	new_one.virtual_key = self.virtual_key
	new_one.val = self.val
	
	new_one.src_msg = self
	
	return new_one
