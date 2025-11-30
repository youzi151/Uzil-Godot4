
## Evt.Listener 偵聽者
## 
## 提供 事件 識別 與 呼叫 執行內容
## 

# Variable ===================

## 標籤
var _tags := []

## 必需標籤
var _require_tags := []

## 只有標籤
var _only_tags := []

## 忽略標籤
var _ignore_tags := []

## 執行內容
var fnc : Callable

## 排序
var sort : int = 0

## 呼叫次數 (預設 無限)
var call_times : int = -1

## 是否啟用
var enabled : bool = true

# GDScript ===================

# Public =====================

## 呼叫事件
func emit (ctrlr) :
	if not self.enabled : return
	
	var is_ctrlr_exist := ctrlr != null
	
	if is_ctrlr_exist :
		ctrlr.set_current_listener(self)
	
	# 雖有 Callable.get_argument_count() 可用.
	# 但應用在有capture區域變數的lambda時, 會因為capture的變數也會被包含其數量中, 導致非預期的結果.
	# 故固定傳入單一變數ctrlr較佳.
	if self.fnc != null :
		await self.fnc.call(ctrlr)
	
	if is_ctrlr_exist :
		await ctrlr.until_resume()
	
	if is_ctrlr_exist : 
		ctrlr.set_current_listener(null)

## 設置 執行內容
func fn (_fn: Callable) :
	self.fnc = _fn
	return self

## 設置 呼叫次數
func times (times: int) :
	self.call_times = times
	return self

## 設置 單次呼叫
func once () :
	self.call_times = 1
	return self

## 設置 排序
func srt (_srt: int) :
	self.sort = _srt
	return self

## 設置 標籤
func tag (_tag: String) :
	if self._tags.has(_tag) : return
	self._tags.push_back(_tag)
	return self

## 必需
func require (tag: String) :
	if not self._require_tags.has(tag) :
		self._require_tags.push_back(tag)
	return self

## 必需
func requires (tags: Array) :
	for each in tags :
		self.require(each)
	return self

## 只有
func only (tag: String) :
	if not self._only_tags.has(tag) :
		self._only_tags.push_back(tag)
	return self

## 只有
func onlys (tags: Array) :
	for each in tags :
		self.only(each)
	return self

## 忽略
func ignore (tag: String) :
	if not self._ignore_tags.has(tag) :
		self._ignore_tags.push_back(tag)
	return self

## 忽略
func ignores (tags: Array) :
	for each in tags :
		self.ignore(each)
	return self

## 是否應該被處理
func should_listen (tags: Array) -> bool :
	# 若 目標標籤 有任一 此偵聽者的忽略標籤 則 不處理
	for each in tags :
		if self._ignore_tags.has(each) : return false
	
	# 若 此偵聽者的必需標籤 有任一 不包含在目標標籤中 則 不處理
	var requires_size : int = self._require_tags.size()
	if requires_size > 0 :
		if tags.size() < requires_size : return false
		for each in self._require_tags :
			if not tags.has(each) :
				return false
			
	
	# 若 目標標籤中 有任一 不在此偵聽者的只有標籤內 則 不處理
	var onlys_size : int = self._only_tags.size()
	if onlys_size > 0 :
		if tags.size() > onlys_size : return false
		for each in tags :
			if not self._only_tags.has(each) :
				return false
	return true
