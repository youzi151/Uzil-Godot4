extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready () :
	
	self.test()

func test_process (_delta) :
	pass


# Public =====================

func test () :
	
	print("Uzil.Core.Vals test")
	
	var vals = G.v.Uzil.Core.Vals.new()
	
	vals.on_update.on(func(ctrlr):
		print("on update to : %s " % vals.current())
	)
	
	vals.set_current_overwrite_fn(func(data):
		return "%s + overwrite" % data.val
	)
	
	vals.set_default("null (default)")
	
	print("set base")
	vals.set_data("sys", "usr_system", 2)
	vals.set_data("func", "usr_functional", 3)
	
	print("set 2")
	vals.set_data("sys2", "usr_system")
	vals.set_data("func2", "usr_functional")
	
	print("set sys pri")
	vals.set_pri("usr_system", 5)
	
	print("final : %s " % vals.current())
	
	
	
