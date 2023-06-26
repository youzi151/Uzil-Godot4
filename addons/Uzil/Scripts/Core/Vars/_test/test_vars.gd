extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready () :
	
	self.test()

func test_process (_delta) :
	pass


# Public =====================

func test () :
	
	print("Uzil.Core.Vars test")
	
	
	var vars = UREQ.acc("Uzil", "vars_mgr").inst()
	
	var listener1 = vars.on_var_changed(func(ctrlr):
		print("vars[%s] set to %s" % [ctrlr.data["key"], ctrlr.data["val"]])
	)
	
	vars.set_var("var1", "test")
	
	print("print var1 : %s" % vars.get_var("var1"))
	
	vars.set_var("var1", null)
	
	vars.off_var_changed(listener1)
	
	vars.set_var("var1", "final")
	
