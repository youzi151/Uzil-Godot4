extends Node

## Evt.Bus 事件串
## 
## 持有多個不同事件的集合
## 

# Variable ===================

# 事件表
var key_to_evt := {}

# GDScript ===================

# Public =====================

## 註冊
func on (evt_key, listener_or_fn) :
	var evt = self.get_evt(evt_key)
		
	# 添加 偵聽者
	var listener = evt.on(listener_or_fn)
	
	return listener
	
## 註銷
func off (evt_key, listener_or_tag) :
	var evt = self.get_evt(evt_key)
	evt.off(listener_or_tag)

## 發送事件
func emit (evt_key, data) :
	var evt = self.get_evt(evt_key)
	evt.emit(data)

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
		evt = G.v.Uzil.Core.Evt.Inst.new()
		self.key_to_evt[evt_key] = evt
	
	return evt
