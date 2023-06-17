extends Uzil_Test_Base

# Variable ===================

var invoker_inst

var is_test_frame := false

# Extends ====================

func test_ready () :
	
	var invoker_mgr = UREQ.access_g("Uzil", "invoker")
	self.invoker_inst = invoker_mgr.inst()
	
	# 單次
#	self.test_once(5000)

	# 間隔
	self.test_interval(3)
	
	# 每幀
#	self.test_update()
	
	# 單格
#	self.test_frame()

func test_process (_delta) :
	if self.is_test_frame:
		print("==========")
		self.invoker_inst.frame(func(): print("A"))
		self.invoker_inst.frame(func(): print("B"), null, 4)
		self.invoker_inst.frame(func(): print("C"))


# Public =====================

func test_once (delay_ms) :
	
	print("once : ",delay_ms)
	
	if delay_ms > 0 :
		print("register new")
		self.invoker_inst.once(func():
			print("to call : ",delay_ms)
		, delay_ms)

func test_interval (num) :
	
	# 要透過參考 否則 會有 閉包取值 問題
	var ref := {
		"num": num,
		"task": null
	}
	
	ref.task = self.invoker_inst.interval(func():
		ref.num = ref.num - 1
		
		print("interval: ",ref.num)
		
		if ref.num <= 0 :
			print("cancel")
			self.invoker_inst.cancel_task(ref.task)
	, 1000)

func test_update () :
	self.invoker_inst.update(func(dt):
		print("update : %s" % dt)
	)
	

func test_frame () :
	
	self.is_test_frame = true
	
	# 其餘 在 _process 裡
	

