extends Uzil_Test_Base

# Variable ===================

var times := []

@export
var spin_panels : Array[NodePath] = []

var _spin_panels : Array[Node] = []

# Extends ====================

func test_ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var times_mgr = UREQ.acc("Uzil", "times_mgr")
	var times_inst_A = times_mgr.inst("A")
	
	self.times.push_back(times_inst_A)
	times_inst_A.set_timing_in_background(true, "test", 0)
	times_inst_A.set_scale(2)
	
	self.times.push_back(times_mgr.inst("B"))
	
#	self.times.push_back(times_mgr.inst("C"))

	for each_path in self.spin_panels :
		var chain : Node = self.get_node(each_path)
		chain.visible = true
		self._spin_panels.push_back(chain)
	
func test_process(_delta):
	var arr := []
	for idx in range(0, self.times.size()) :
		var each = self.times[idx]
		arr.push_back(each.name)
		arr.push_back(each.now())
		(self._spin_panels[idx] as Control).rotation_degrees += 50 * each.dt() * 0.001
	
	print("%s:%s, %s:%s" % arr)

# GDScript ===================

func _notification(what) :
	if not self.active : return
	match what :
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN :
			print("focus in")
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT :
			print("focus out")

# Public =====================
