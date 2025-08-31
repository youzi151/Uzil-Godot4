extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

signal on_signal

var wait_ctrlrs : Array = []

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_signals")
	

func _exit_tree () :
	G.off_print("test_signals")


# Extends ====================

# Public =====================

func test_emit () :
	self.on_signal.emit()

func test_wait_ctrlr_single () :
	G.print("wait_ctrlr single start")
	
	var wait_ctrlr = UREQ.acc(&"Uzil:Util").signals.wait_ctrlr(self.on_signal)
	
	G.print("on_signal connected: %s" % [self.on_signal.get_connections().size()])
	
	await wait_ctrlr.until_emit()
	
	wait_ctrlr = null
	
	G.print("wait_ctrlr single done")

func test_wait_ctrlr_queue () :
	G.print("wait_ctrlr queue start")
	
	var wait_ctrlr = UREQ.acc(&"Uzil:Util").signals.wait_ctrlr(self.on_signal)
	self.wait_ctrlrs.push_back(wait_ctrlr)
	
	G.print("on_signal connected: %s" % [self.on_signal.get_connections().size()])
	
	await wait_ctrlr.until_emit()
	
	G.print("wait_ctrlr queue done")

func test_wait_ctrlr_clear () :
	G.print("on_signal connected: %s" % [self.on_signal.get_connections().size()])
	
	for each in self.wait_ctrlrs :
		each.close()
	self.wait_ctrlrs.clear()
	
	G.print("wait_ctrlrs clear")
	G.print("on_signal connected: %s" % [self.on_signal.get_connections().size()])

func test_wait_ctrlr_fail () :
	G.print("wait_ctrlr fail start")
	
	var wait_ctrlr = UREQ.acc(&"Uzil:Util").signals.wait_ctrlr(self.on_signal)
	
	var connect_count_before : int = self.on_signal.get_connections().size()
	G.print("on_signal connected: %s" % [connect_count_before])
	
	
	var step_second = func():
		await wait_ctrlr.until_emit()
		G.print("wait_ctrlr fail done")
	step_second.call()
	
	# 釋放引用
	wait_ctrlr = null
	
	# 沒有 因為 引用歸零 而被自動解除
	G.print("on_signal connected: %s == %s" % [connect_count_before, self.on_signal.get_connections().size()])
	
	
