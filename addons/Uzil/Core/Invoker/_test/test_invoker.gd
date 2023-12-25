extends Node

# Variable ===================

var invoker_inst

## 是否測試每幀
var is_test_frame := false

## 幀錯文字
@export
var debug_label : TextEdit

## 單次呼叫任務
var once_task = null
## 間隔呼叫任務
var interval_tasks := []
## 每幀呼叫任務 標籤
var update_task_tag := ""

# GDScript ===================

func _ready () :
	
	var invoker_mgr = UREQ.acc("Uzil", "invoker")
	self.invoker_inst = invoker_mgr.inst()
	
	G.on_print(func (msg):
		self.debug_label.text += msg+"\n"
	, "test_invoker")

func _process (_delta) :
	if self.is_test_frame:
		
		# 同一幀 以內
		G.print("=frame=========")
		
		var tag_a = "a"
		var tag_b = "b"
		
		# 會被取消並覆蓋的
		self.invoker_inst.frame(func(): G.print("a : will be cancel"), tag_a)
		G.print("ask to update A1")
		# 優先度高 唯一能執行的
		self.invoker_inst.frame(func(): G.print("a : the only one can be execute"), tag_a, 4)
		G.print("ask to update A2")
		# 另外一組標籤, 不會受影響
		self.invoker_inst.frame(func(): G.print("b : execute"), tag_b)
		G.print("ask to update B1")
		# 優先度較低, 會被忽略的
		self.invoker_inst.frame(func(): G.print("a : will be ignore"), tag_a)
		G.print("ask to update A3")
		
		G.print("result:")

func _exit_tree () :
	
	if self.once_task != null : 
		self.invoker_inst.cancel_task(self.once_task)
	
	for each in self.interval_tasks :
		self.invoker_inst.cancel_tag("test_interval")
	
	if not self.update_task_tag.is_empty() :
		self.invoker_inst.cancel_tag(self.update_task_tag)
		self.update_task_tag = ""
	
	G.off_print("test_invoker")

# Extends ====================

# Public =====================

## 單次
func test_once (delay_ms : int = 3000) :
	
	# 若 尚未被建立
	if self.once_task == null :
		
		G.print("once after: %s" % delay_ms)
		
		# 數秒後執行
		self.once_task = self.invoker_inst.once(func():
			self.once_task = null
			G.print("call after %s ms" % delay_ms)
		, delay_ms)
		
	# 若已經被建立
	else :
		# 取消呼叫
		self.invoker_inst.cancel_task(self.once_task)
		self.once_task = null
		G.print("cancel once task")

## 間隔
func test_interval (times : int = 3) :
	G.print("start call %s times" % times)
	
	# 要透過參考 否則 會有 閉包取值 問題
	var ref := {
		"times": times,
		"task": null
	}
	
	# 間隔呼叫
	ref["task"] = self.invoker_inst.interval(func():
		
		G.print("interval: %s" % ref.times)
		
		# 扣除計數
		ref.times = ref.times - 1
		# 若已經扣除完畢
		if ref.times <= 0 :
			# 取消間隔呼叫
			G.print("cancel")
			self.invoker_inst.cancel_task(ref["task"])
			
	, 1000).tag("test_interval")

## 每幀
func test_update () :
	
	# 若尚未建立
	if self.update_task_tag.is_empty() :
		
		self.update_task_tag = "test_update"
		
		# 每幀呼叫
		self.invoker_inst.update(func(dt):
			G.print("update : dt[%s]" % dt)
		).tag(self.update_task_tag)
	
	# 若已經建立
	else :
		# 以tag取消任務
		self.invoker_inst.cancel_tag(self.update_task_tag)
		self.update_task_tag = ""

## 單格
func test_frame () :
	self.is_test_frame = not self.is_test_frame	
	# 其餘 在 _process 裡
	

