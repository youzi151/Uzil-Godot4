extends Node


# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export
var is_updating_checkbox : CheckBox

var _to_print := ""

var listeners : Array = []

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.set_text(msg)
	, "test_input_pipe")
	
	self.is_updating_checkbox.pressed.connect(func():
		if self.is_updating_checkbox.button_pressed :
			self.test_enter()
		else :
			self.test_exit()
	)
	
	self.test_enter()
	
	var invoker = UREQ.acc("Uzil", "invoker")
	invoker.interval(func():
		if not self.is_updating_checkbox.button_pressed : return
		if self._to_print == "" : return
		
		G.print(self._to_print)
		self._to_print = ""
		
	, 100)

func _process (_delta) :
	pass

func _exit_tree () :
	
	self.test_exit()
	
	G.off_print("test_input_pipe")

# Extends ====================

# Public =====================

func test_enter () :
	var InputPipe = UREQ.acc("Uzil", "InputPipe")
	var input_pipe = UREQ.acc("Uzil", "input_pipe")
	var Util = UREQ.acc("Uzil", "Util")
	
	# Layer 與 Handler 建立 ==========
	
	# 建立 Layer
	var input_layer1 = input_pipe.get_layer("L1").sort(1)
	var input_layer2 = input_pipe.get_layer("L2").sort(2)
	var input_layer3 = input_pipe.get_layer("L3").sort(3)
	var input_layer4 = input_pipe.get_layer("L4").sort(4)
	
	# 建立 Handler
	# 輸入處理器 S -> 8888
	var handler2 = InputPipe.new_handler("handler2", "keyconvert", {
		"srt" : 0,
		"src" : [Util.input.keycode.name_to_keycode("key.s")],
		"dst" : 8888
	})
	# 輸入處理器 A -> 1111
	var handler1 = InputPipe.new_handler("handler1", "keyconvert", {
		"srt" : -1,
		"src" : [Util.input.keycode.name_to_keycode("key.a")],
		"dst" : 1111
	})
	
	# 各Layer 加入 Handler1 (key.a)
	input_layer1.add_handler(handler1)
	input_layer2.add_handler(handler1)
	input_layer3.add_handler(handler1)
	input_layer4.add_handler(handler1)
	
	# 各Layer 加入 Handler2 (key.s)
	input_layer1.add_handler(handler2)
	input_layer2.add_handler(handler2)
	input_layer3.add_handler(handler2)
	
	
	# 向 Layer 註冊 輸入 事件 =========
	
	# Layer1 ===
	
	# Listener1
	input_layer1.on_input(1111, func(ctrlr):
		
		self._to_print = ""
		
		var input_msg = ctrlr.data
		self.to_print("Layer1 1 key[1111] val:%s" % input_msg.val)
		
		# 若 值 為 按下
		if input_msg.val == Util.input.ButtonState.PRESSED :
			# 標記 忽略 偵聽tag
			# 忽略 對 之後有對應tag的listener
			ctrlr.ignore("to_ignore_listener_a")
			# 忽略 對 之後有對應tag的layer
			input_msg.ignore("to_ignore_listener_a")
	)
	# Listener2
	input_layer1.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer1 2 key[1111] val:%s (should be ignore when pressed)" % input_msg.val)
	).tag("to_ignore_listener_a")
	
	# Listener3
	input_layer1.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer1 3 key[1111] val:%s" % input_msg.val)
		# 若 值 為 按下
		if input_msg.val == Util.input.ButtonState.PRESSED :
			ctrlr.stop()
#			input_msg.stop()
	)
	
	# Listener4
	input_layer1.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer1 4 key[1111] val:%s (should stop before this when pressed)" % input_msg.val)
	)
	
	# Listener(8888)
	input_layer1.on_input(8888, func(ctrlr):
		var input_msg = ctrlr.data
		var val_modified = input_msg.val
		self.to_print("Layer1 key[8888] val:%s isAlive:%s" % [val_modified, input_msg.is_alive()])
	)
	
	# Layer2 ===

	# Listener(1111) (應要被tag忽略 所以此處不會接收到事件)
	input_layer2.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer2 key[1111] val:%s isAlive:%s (should be ignore when pressed)" % [input_msg.val, input_msg.is_alive()])
	).tag("to_ignore_listener_a")
	
	# Listener(8888)
	input_layer2.on_input(8888, func(ctrlr):
		var input_msg = ctrlr.data
		var val_modified = input_msg.val
		
		var msg_1111 = input_layer2.get_msg(1111)
		# 若 1111輸入 的 值 存在
		if msg_1111 != null :
			# 若 值 為 按下
			if msg_1111.val == Util.input.ButtonState.PRESSED :
				# 改 得到的值 為 0
				val_modified = 0
				
		self.to_print("Layer2 key[8888] val:%s isAlive:%s" % [val_modified, input_msg.is_alive()])
	)
	
	# Layer3 ===
	
	# Listener(1111)
	input_layer3.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer3 key[1111] val:%s isAlive:%s" % [input_msg.val, input_msg.is_alive()])
		if input_msg.val == 1 :
			input_msg.stop()
	)
	
	# Listener(8888)
	input_layer3.on_input(8888, func(ctrlr):
		var input_msg = ctrlr.data
		var val_modified = input_msg.val
		
		var msg_1111 = input_layer3.get_msg(1111)
		# 若 1111輸入 的 值 存在
		if msg_1111 != null :
			# 若 值 為 按下
			if msg_1111.val == Util.input.ButtonState.PRESSED :
				# 若 應該要處理
				if msg_1111.should_handle(["to_ignore_listener_a"]):
					# 改 得到的值 為 0
					val_modified = 0
		
		self.to_print("Layer3 key[8888] val:%s isAlive:%s" % [val_modified, input_msg.is_alive()])
	)
	
	# Layer4 ===
	
	# Listener(1111) (應要被Layer3.Listener1給stop 所以此層以後不會接收到事件)
	input_layer4.on_input(1111, func(ctrlr):
		var input_msg = ctrlr.data
		self.to_print("Layer4 key[1111] val:%s isAlive:%s (can stop before this)" % [input_msg.val, input_msg.is_alive()])
	)
	
#	UREQ.acc("Uzil", "invoker").once(func():
#		input_layer1.aaaaa(false)
#	, 2000)

func test_exit () :
	var input_pipe = UREQ.acc("Uzil", "input_pipe")
	
	#input_pipe.clear()
	
	# or
	
	input_pipe.del_layer("L1")
	input_pipe.del_layer("L2")
	input_pipe.del_layer("L3")
	input_pipe.del_layer("L4")
	
	

func to_print (msg) :
	self._to_print += msg+"\n"
