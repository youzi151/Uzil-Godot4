
## Evt.Inst 事件
## 
## 可將 事件與資料 呼叫 給 註冊的 多個 偵聽者
## 

var Evt

# Variable ===================

## 是否自動排序
var is_auto_sort := false

## 偵聽者
var _listener_list := []

# GDScript ===================

func _init () :
	self.Evt = UREQ.acc("Uzil", "Core.Evt")

# Public =====================

## 呼叫事件
func emit (data = null) :
	# 自動排序
	if self.is_auto_sort :
		self.sort()
	
	# 控制
	var ctrlr = self.Evt.CallCtrlr.new(self)
	ctrlr.data = data
	
	# 每個 偵聽者
	var listeners_copy := self._listener_list.duplicate()
	for each in listeners_copy :
		# 若已經被移除 則 繼續 下個
		if not self._listener_list.has(each) : continue
		# 若 控制終止
		if ctrlr.is_call_stop() : break
		
		# 呼叫
		each.emit(ctrlr)

## 新增 偵聽者
func on (listener_or_fn) :
	var typ := typeof(listener_or_fn)
	
	# 處理 參數 偵聽者
	var listener
	if typ == TYPE_CALLABLE :
		listener = self.Evt.Listener.new()
		listener.fn(listener_or_fn)
	elif typ == TYPE_OBJECT and  listener_or_fn.get_script() == self.Evt.Listener :
		listener = listener_or_fn
	else :
		return listener
		
	if self._listener_list.has(listener) :
		return listener
		
	if typeof(listener) == TYPE_OBJECT and (listener as Object).get_script() == self.Evt.Listener :
		self._listener_list.push_back(listener)
		
	return listener

## 移除 (自動判定)
func off (listener_or_tag) :
	var typ := typeof(listener_or_tag)
	
	match typ :
		TYPE_STRING :
			self.off_by_tag(listener_or_tag)
		
		TYPE_ARRAY :
			for each in listener_or_tag :
				if typeof(each) == TYPE_STRING :
					self.off_by_tag(each)
				
		TYPE_OBJECT :
			if (listener_or_tag as Object).get_script() == self.Evt.Listener :
				self.off_by_listener(listener_or_tag)

## 移除 該標籤的偵聽者
func off_by_tag (tag) :
	for idx in range(self._listener_list.size()-1, -1, -1) :
		var each = self._listener_list[idx]
		if each.tags.has(tag) :
			self._listener_list.erase(each)

## 移除 偵聽者
func off_by_listener (listener) :
	if self._listener_list.has(listener) : 
		self._listener_list.erase(listener)

## 清空
func clear () :
	self._listener_list.clear()

## 排序
func sort () :
	self._listener_list.sort_custom(func(a, b):
		return a.sort < b.sort
	)
