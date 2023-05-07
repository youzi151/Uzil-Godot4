extends Uzil_Test_Base

# Variable ===================

@export var pagecard_inst_nodepath : NodePath

var pagecard_inst


# Extends ====================

func test_ready():
	self.pagecard_inst = self.get_node(self.pagecard_inst_nodepath)
	
	self.pagecard_inst.on_ready.on(func (_ctrlr) :
		G.v.Uzil.Util.async.waterfall([
			func (ctrlr) :
				print("page1 task")
				self.pagecard_inst.go_page("page1")
				G.v.Uzil.invoker.inst().once(ctrlr.next, 1000),
			func (ctrlr) :
				print("page2 task")
				self.pagecard_inst.go_page("page2")
				G.v.Uzil.invoker.inst().once(ctrlr.next, 1000),
			func (ctrlr) :
				print("page3 task")
				self.pagecard_inst.go_page("page3")
				G.v.Uzil.invoker.inst().once(ctrlr.next, 1000)
		])
		
	)

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

