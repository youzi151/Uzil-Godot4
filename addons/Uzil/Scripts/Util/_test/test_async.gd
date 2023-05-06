extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready () :
#	self.test_waterfall()
#	self.test_parallel()
#	self.test_each_series_list()
#	self.test_each_series_dict()
#	self.test_each_list()
#	self.test_each_dict()
#	self.test_times_series()
	self.test_times()
	

func test_process (_delta) :
	pass

# Public =====================

func test_waterfall () :
	
	print("test : Uzil.Util.async.waterfall")
	
	G.v.Uzil.Util.async.waterfall(
		[
			func (ctrlr) :
				print("A")
				ctrlr.next.call(),
			func (ctrlr) :
				print("B")
				G.v.Uzil.invoker.inst().once(func () :
					ctrlr.next.call()
				, 1000),
			func (ctrlr) :
				print("C")
#				ctrlr.stop.call()
				ctrlr.skip.call()
				,
			func (ctrlr) :
				print("D")
				ctrlr.next.call(),
		],
		func () :
			print("final")
	)
	
func test_parallel () :
	
	print("test : Uzil.Util.async.parallel")
	
	G.v.Uzil.Util.async.parallel(
		[
			func (ctrlr) :
				print("A")
				ctrlr.next.call()
#				ctrlr.skip.call()
				,
			func (ctrlr) :
				G.v.Uzil.invoker.inst().once(func () :
					print("B")
					ctrlr.next.call()
				, 1000)
				,
			func (ctrlr) :
				print("C")
				ctrlr.stop.call()
				,
		],
		func () :
			print("final")
	)

func test_each_series_list () :
	
	print("test : Uzil.Util.async.each_series")
	
	G.v.Uzil.Util.async.each_series(
		["hello", "world", "godot"],
		func (idx, each, ctrlr) :
			G.v.Uzil.invoker.inst().once(func () :
				print("%s : %s" % [idx, each])
				
				if idx == 1 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else : 
					ctrlr.next.call()
				
			, 3000-(500*idx)),
		func () :
			print("final")
	)
	
func test_each_series_dict () :
	
	print("test : Uzil.Util.async.each_series")
	
	G.v.Uzil.Util.async.each_series(
		{"first": "hello", "second": "world", "third": "godot"},
		func (key, each, ctrlr) :
			G.v.Uzil.invoker.inst().once(func () :
				print("%s : %s" % [key, each])
				
				if key == "second" : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else : 
					ctrlr.next.call()
				
			, 2000),
		func () :
			print("final")
	)


func test_each_list () :
	
	print("test : Uzil.Util.async.each")
	
	G.v.Uzil.Util.async.each(
		["hello", "world", "godot"],
		func (idx, each, ctrlr) :
			G.v.Uzil.invoker.inst().once(func () :
				print("%s : %s" % [idx, each])
				if idx == 1 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, 3000-(500*idx)),
		func () :
			print("final")
	)

func test_each_dict () :
	
	print("test : Uzil.Util.async.each")
	
	var ref := {}
	ref.delay = 3000
	
	G.v.Uzil.Util.async.each(
		{"first": "hello", "second": "world", "third": "godot"},
		func (key, each, ctrlr) :
			ref.delay -= 500
			G.v.Uzil.invoker.inst().once(func () :
				print("%s : %s" % [key, each])
				if key == "second" : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, ref.delay),
		func () :
			print("final")
	)

func test_times_series () :
	
	print("test : Uzil.Util.async.times_series")
	
	G.v.Uzil.Util.async.times_series(
		5,
		func (idx, ctrlr) :
			G.v.Uzil.invoker.inst().once(func () :
				print(idx)
				if idx == 2 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
					
			, 3000-(500*idx)),
		func () :
			print("final")
	)

func test_times () :
	
	print("test : Uzil.Util.async.times")
	
	G.v.Uzil.Util.async.times(
		5,
		func (idx, ctrlr) :
			G.v.Uzil.invoker.inst().once(func () :
				print(idx)
				if idx == 2 : 
#					ctrlr.skip.call()
					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, 2000),
		func () :
			print("final")
	)
