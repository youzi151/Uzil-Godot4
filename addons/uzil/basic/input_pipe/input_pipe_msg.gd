
## InputPipe.Msg 輸入管道 訊號
##
## 代表 一個 由 實際輸入 到 虛擬輸入 的 輸入相關訊號資料.
## 

# Variable ===================

## 辨識
var id := ""

## 是否啟用
var _is_alive := true

## 標籤
var _tags : Array[String] = []

## 實際 key
var real_key := 0

## 虛擬 key
var virtual_key := 0

## 排序
var sort := 0

## 來源訊號
var src_msg = null

## 值
var val = null

# GDScript ===================

# Extends ====================

# Public =====================

## 初始化
func init (key: int) :
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


## 標籤 (不傳遞給之後缺少對應tag的layer)
func tag (_tag: String, is_src_streamed := true) :
	if not self._tags.has(_tag) :
		self._tags.push_back(_tag)
	# 若 要 連同 源頭
	if is_src_streamed :
		if self.src_msg != null :
			return self.src_msg.tag(_tag, true)

## 標籤
func tags (_tags: Array, is_src_streamed := true) :
	for each in _tags :
		self.tag(each, is_src_streamed)

## 取得 標籤
func get_tags (is_src_streamed := true) -> Array[String] :
	# 若 要 連同 源頭
	if is_src_streamed : 
		if self.src_msg != null :
			var tags : Array[String] = self.src_msg.get_tags().duplicate()
			for each in self._tags :
				if not tags.has(each) :
					tags.push_back(each)
			return tags
	
	return self._tags

## 是否包含有任意指定標籤
func has_any_tag (target_tags: Array, is_src_streamed := true) -> bool :
	var tags : Array[String] = self.get_tags(is_src_streamed)
	for each in target_tags :
		if tags.has(each) : return true
	return false

## 是否包含所有指定標籤
func has_all_tag (target_tags: Array, is_src_streamed := true) -> bool :
	var tags : Array[String] = self.get_tags(is_src_streamed)
	if target_tags.size() > tags.size() : return false
	for each in target_tags :
		if not tags.has(each) : return false
	return true


## 終止 (不傳遞給之後的layer)
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
