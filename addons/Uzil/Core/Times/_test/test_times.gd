extends Uzil_Test_Base

# Variable ===================

var times := []

## 偵錯文字
@export
var debug_log : Node = null

@export
var spin_panels : Array[Node] = []

var is_test_spin := false

# Extends ====================

# GDScript ===================

func _ready():
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_times")
	
	
func _process(_delta):
	
	if self.is_test_spin :
		
		var debug_arr := []
		
		for idx in range(0, self.times.size()) :
			var each = self.times[idx]
			var dt : int = each.dt()
			
			# 以 delta_time 旋轉
			(self.spin_panels[idx] as Control).rotation_degrees += 50 * dt * 0.001
			
			# 紀錄 名稱與當下時間
			debug_arr.push_back(each.name)
			debug_arr.push_back(each.now())
			debug_arr.push_back(dt)
		
		G.print("%s:%s dt(%s)  |  %s:%s  dt(%s)" % debug_arr)


func _notification(what) :
	match what :
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN :
			G.print("focus in")
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT :
			G.print("focus out")

func _exit_tree () :
	
	G.off_print("test_times")

# Public =====================

func test_normal () :
	
	if self.is_test_spin : 
		self.is_test_spin = false
		return
	else :
		self.is_test_spin = true
	
	self.times.clear()
	
	
	# 時間實體管理
	var times_mgr = UREQ.acc("Uzil", "times_mgr")
	
	
	# 時間實體 A ====
	self.times.push_back(times_mgr.inst("A"))
	
	# 時間實體 B ====
	var times_inst_B = times_mgr.inst("B")
	
	# 設置 是否在背景計時 true:計時, "test":使用者, 0:設置優先度
	# (以Vals機制設置, 詳見Vals)
	times_inst_B.set_timing_in_background(true, "test", 0)
	
	# 設置時間比例
	times_inst_B.set_scale(2)
	
	self.times.push_back(times_inst_B)
	
	

