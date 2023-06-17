extends Uzil_Test_Base

# Variable ===================

var Evt

# Extends ====================

func test_ready () :
	self.Evt = UREQ.access_g("Uzil", "Core.Evt")
#	self.test1()
	self.test2()
	

func test_process (_delta) :
	pass

# Public =====================

func test1 () :
	print("Evt Test1")
	
	var test_evt = self.Evt.Inst.new()
	
	var listener3 = self.Evt.Listener.new().fn(func(_ctrlr):
		print("3 data : %s" % (_ctrlr.data))
	).tag("3").srt(3)
	
	var listener2 = self.Evt.Listener.new().fn(func(_ctrlr):
		print("2 data : %s" % (_ctrlr.data))
	).tag("2").srt(2)
	
	var listener1 = self.Evt.Listener.new().fn(func(_ctrlr):
		print("1 data")
	).tag("1").srt(1)
	
	test_evt.on(listener1)
	test_evt.on(listener2)
	test_evt.on(listener3)
	
	test_evt.sort()
	
	test_evt.off("2")
	
	test_evt.emit("test") 
	
func test2 () :
	
	print("Evt Test2")
	
	var evtbus = UREQ.access_g("Uzil", "evt_bus_mgr").inst("test")
	
	var listener = evtbus.on("onTestCall", func (ctrlr) :
		print("onTestCall : 0 : %s" % (ctrlr.data["msg"]))
	)
	
	var listener_to_del = evtbus.on("onTestCall", func (_ctrlr) :
		print("onTestCall : should be delete")
	)
	
	var sort = -1
#	var sort = 1
	evtbus.on("onTestCall", self.Evt.Listener.new().fn(func (_ctrlr) :
		var data = _ctrlr.data
		print("onTestCall : sort[%s] : msg[%s]" % [sort, data["msg"]])
		evtbus.off("onTestCall", listener_to_del)
		_ctrlr.stop()
	).srt(sort))
	
	evtbus.sort()
	
	
	evtbus.emit("onTestCall", {
		"msg" : "hello"
	})
