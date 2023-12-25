extends Node

# Variable ===================

var Evt

@export
var debug_label : TextEdit

# Extends ====================

func _ready () :
	G.on_print(func(msg) : 
		self.debug_label.text += msg+"\n"
	, "test_evt")
	
	# 事先引用 Evt
	self.Evt = UREQ.acc("Uzil", "Core.Evt")

func _process (_delta) :
	pass

func _exit_tree () :
	G.off_print("test_evt")

# Public =====================

## 一般測試
# 測試事件中的資料或呼叫, 在各偵聽者上的操作與影響
func test_normal () :
	G.print("== Evt Test")
	
	# 建立 事件
	var test_evt = self.Evt.Inst.new()
	
	# 建立 幀聽 4號
	var listener4 = self.Evt.Listener.new().fn(func(_ctrlr):
		# 印出事件資料
		G.print("[4] data : %s" % (_ctrlr.data))
	).tag("4").srt(4)
	
	# 建立 幀聽 3號
	var listener3 = self.Evt.Listener.new().fn(func(_ctrlr):
		# 印出事件資料
		G.print("[3] data : %s" % (_ctrlr.data))
	).tag("3").srt(3)
	
	# 建立 幀聽 1號
	var listener1 = self.Evt.Listener.new().fn(func(_ctrlr):
		# 印出事件資料
		G.print("[1] data : %s" % (_ctrlr.data))
		
		# 中途 改變 事件資料
		_ctrlr.data = _ctrlr.data+" changed"
		G.print("change data to \"%s\"" % (_ctrlr.data))
		
	).tag("1").srt(1)
	
	# 建立 幀聽 2號
	var listener2 = self.Evt.Listener.new().fn(func(_ctrlr):
		# 印出事件資料
		G.print("[2] data : %s" % (_ctrlr.data))
		
		# 標記忽略tag "3"
		G.print("ignore tag \"3\"")
		_ctrlr.ignore("3")
		
		# 中途移除 幀聽 4號
		G.print("off listener4")
		test_evt.off(listener4)
		
		
	).tag("2").srt(2)
	
	# 建立 幀聽 5號
	var listener5 = self.Evt.Listener.new().fn(func(_ctrlr):
		# 印出事件資料
		G.print("[5] data : %s" % (_ctrlr.data))
		
		# 停止事件
		_ctrlr.stop()
		G.print("stop emit")
		
	).tag("5").srt(5)
	
	# 建立 幀聽 6號
	var listener6 = self.Evt.Listener.new().fn(func(_ctrlr):
		G.print("[6] data : %s" % (_ctrlr.data))
	).tag("6").srt(6)
	
	# 註冊 所有幀聽 
	test_evt.on(listener1)
	test_evt.on(listener2)
	test_evt.on(listener3)
	test_evt.on(listener4)
	test_evt.on(listener5)
	test_evt.on(listener6)
	
	# 排序
	test_evt.sort()
	
	# 發送事件
	test_evt.emit("data_str") 

## 測試 事件串
func test_evtbus () :
	
	G.print("== EvtBus Test")
	
	# 存取 EventBus 實體 "test"
	var evtbus = UREQ.acc("Uzil", "evt_bus_mgr").inst("test")
	evtbus.clear()
	
	# 註冊 幀聽 1號
	var listener = evtbus.on("onTestCall", func (ctrlr) :
		G.print("onTestCall : listener1 : %s" % (ctrlr.data["msg"]))
	).srt(10)
	
	# 註冊 幀聽 2號(待移除)
	var listener_to_del = evtbus.on("onTestCall", func (_ctrlr) :
		G.print("onTestCall : should be delete")
	).srt(20)
	
	# 註冊 幀聽 3號
	var sort = 15 # 排序
	evtbus.on("onTestCall", self.Evt.Listener.new().fn(func (_ctrlr) :
		var data = _ctrlr.data
		G.print("onTestCall : listener3 sort[%s] : msg[%s]" % [sort, data["msg"]])
		
		# 註銷偵聽3號
		evtbus.off("onTestCall", listener_to_del)
		
		# 停止繼續下一個偵聽者
		_ctrlr.stop()
		
	).srt(sort))
	
	# 排序
	evtbus.sort()
	
	# 發送事件
	evtbus.emit("onTestCall", {
		"msg" : "hello"
	})
