
## Evt.Bus 事件串
## 
## 持有多個不同事件的集合
## 

# Variable ===================

## 事件表
var key_to_evt := {}

# GDScript ===================

func init (_dont_set_in_scene) :
	pass
	

# Public =====================

## 註冊
func on (evt_key : String, listener_or_fn) :
	var evt = self.get_evt(evt_key)
	# 添加 偵聽者
	var listener = evt.on(listener_or_fn)
	return listener

## 註銷
func off (evt_key, listener_or_tag) :
	var evt = self.get_evt(evt_key)
	evt.off(listener_or_tag)

## 註銷
func off_each (listener_or_tag) :
	for each in key_to_evt.values() :
		each.off(listener_or_tag)

## 清空
func clear (evt_key = null) :
	# 若有指定
	if evt_key != null :
		# 若指定存在 則 
		if self.key_to_evt.has(evt_key) :
			# 事件 清空幀聽者
			self.key_to_evt[evt_key].clear()
			# 移除 事件
			self.key_to_evt.erase(evt_key)
	# 若沒有特別指定
	else :
		# 每個事件 清空幀聽者
		for key in self.key_to_evt :
			self.key_to_evt[key].clear()
		# 清空事件列表
		self.key_to_evt.clear()

## 發送事件
func emit (evt_key : String, data) :
	var evt = self.get_evt(evt_key)
	evt.emit(data)
	var any_evt = self.get_evt("")
	any_evt.emit(data)

## 排序
func sort (_evt_key = null) :
	if _evt_key != null :
		var evt = self.get_evt(_evt_key)
		evt.sort()
	else :
		for key in self.key_to_evt :
			self.key_to_evt[key].sort()

## 取得/建立 事件
func get_evt (evt_key) :
	var evt
	
	if self.key_to_evt.has(evt_key) :
		evt = self.key_to_evt[evt_key]
	else : 
		var Evt = UREQ.acc("Uzil", "Core.Evt")
		evt = Evt.Inst.new()
		self.key_to_evt[evt_key] = evt
	
	return evt
