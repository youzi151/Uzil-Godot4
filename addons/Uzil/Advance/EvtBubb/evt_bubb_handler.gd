extends Object


# Variable ===================

var tags : Array[String] = []

var handle_fn : Callable

var next : Object

var get_next_fn : Callable

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

func bubbling (evt) :
	
	var is_handled : bool = true
	
	# 若 要處理
	if self._is_handle(evt) :
		# 呼叫處理
		self.handle_fn.call(evt)
		# 檢查 事件是否已經被處理
		is_handled = evt.is_handled
	
	# 若 不要處理
	else :
		is_handled = false
	
	# 若 沒處理
	if not is_handled :
		# 加入紀錄
		#evt.push_history(self)
		# 找尋下一個
		var next = self._get_next()
		if next != null and next.has_method("bubbling"):
			next.bubbling(evt)

# Public =====================

# Private ====================

## 是否要處理
func _is_handle (evt) :
	if self.handle_fn.is_null() : return false
	if evt.is_ignore(self.tags) : return false
	return true

## 取得下一個
func _get_next () :
	
	if self.next != null :
		return self.next
	
	if not self.get_next_fn.is_null() : 
		var next = self.get_next_fn.call()
		if next != null :
			return next
	
	return null
