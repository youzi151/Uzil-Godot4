extends Node

# Variable ===================

@export
var log_label_NP : NodePath = ""

var log_label : RichTextLabel

var is_accync_binded := false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	self.log_label = self.get_node(self.log_label_NP)
	G.on_print(func(msg):
		self.log_label.append_text(msg+"\n")
	)
	
func test_acc () :
	
	var exist = UREQ.acc(&"test_acc:A")
	
	if exist == null :
		# 綁定 A模塊 : 設置腳本, 依賴 B模塊
		UREQ.bind(&"test_acc", &"A", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_a.gd"), {
			"requires" : ["B"]
		})
		
		# 綁定 B模塊 : 設置腳本, 依賴 C,D模塊
		UREQ.bind(&"test_acc", &"B", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_b.gd"), {
			"requires" : ["C"],
		})
		
		# 綁定 C模塊 : 設置腳本
		UREQ.bind(&"test_acc", &"C", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_c.gd"))
	
	var res = UREQ.acc(&"test_acc:A")
	G.print("test_acc sometext : %s " % res.some_text)
	

func test_accync () :
	
	var scope = UREQ.scope(&"test_accync")
	
	if not self.is_accync_binded :
		self.is_accync_binded = true
		
		# 綁定 A模塊 : 設置腳本, 依賴 B模塊
		scope.bind(&"A", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_a.gd"), {
			"requires" : [&"B"]
		})
		
		# 綁定 B模塊 : 設置腳本, 依賴 C,D模塊
		scope.bind(&"B", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_b.gd"), {
			"requires" : [&"C", &"D"],
		})
		
		# 綁定 C模塊 : 設置腳本
		scope.bind(&"C", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_c.gd"))
		
		# 綁定 D模塊 : 設置腳本, 依賴 C模塊, 等待一下模塊
		scope.bind(&"D", UREQ.ROOT_PATH.path_join("_test/modules/test_ureq_module_d.gd"), {
			"requires" : [&"C", &"wait_sec"]
		})
		
		# 綁定 等待一下模塊 : 設置建立行為(等待3秒, 非同步)
		scope.bind(&"wait_sec", 
			func():
				var timer = self.get_tree().create_timer(3)
				await timer.timeout
				G.print("wait_done")
				return {}
				,
			{
				"is_async" : true
			}
		)
		
	var time := Time.get_ticks_msec()
	# 以非同步方式 存取A模塊
	G.print("start accync(\"A\") (%s) " % time)
	
	await scope.accync("A")
	G.print("A loaded (%s) at %s" % [time, Time.get_ticks_msec()])
	
	#scope.accync("A", func(result):
		#G.print("A loaded (%s) at %s" % [time, Time.get_ticks_msec()])
	#)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
