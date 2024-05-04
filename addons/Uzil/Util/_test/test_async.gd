extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

var Util
var invoker

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_async")
	
	self.invoker = UREQ.acc("Uzil", "invoker_mgr")
	self.Util = UREQ.acc("Uzil", "Util")

func _exit_tree () :
	G.off_print("test_async")


# Extends ====================

# Public =====================

func test_waterfall () :
	
	G.print("test : Uzil.Util.async.waterfall")
	
	self.Util.async.waterfall(
		[
			func(ctrlr):
				G.print("A")
				ctrlr.next.call(),
			func(ctrlr):
				G.print("B")
				self.invoker.inst().once(func():
					ctrlr.next.call()
				, 1000),
			func(ctrlr):
				G.print("C")
#				ctrlr.stop.call()
				ctrlr.skip.call()
				,
			func(ctrlr):
				G.print("D")
				ctrlr.next.call(),
		],
		func():
			G.print("final")
	)
	
func test_parallel () :
	
	G.print("test : Uzil.Util.async.parallel")
	
	await self.Util.async.parallel(
		[
			func(ctrlr):
				G.print("A")
				ctrlr.next.call()
				# ctrlr.skip.call()
				,
			func(ctrlr):
				self.invoker.inst().once(func():
					G.print("B")
					ctrlr.next.call()
				, 1000)
				,
			func(ctrlr):
				G.print("C")
				ctrlr.next.call()
				# ctrlr.stop.call()
				,
		],
		#func():
			#G.print("final")
	)
	G.print("final")

func test_each_series_list () :
	
	G.print("test : Uzil.Util.async.each_series")
	
	self.Util.async.each_series(
		["hello", "world", "godot"],
		func(idx, each, ctrlr) :
			self.invoker.inst().once(func():
				G.print("%s : %s" % [idx, each])
				
				if idx == 1 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else : 
					ctrlr.next.call()
				
			, 3000-(500*idx)),
		func() :
			G.print("final")
	)
	
func test_each_series_dict () :
	
	G.print("test : Uzil.Util.async.each_series")
	
	self.Util.async.each_series(
		{"first": "hello", "second": "world", "third": "godot"},
		func(key, each, ctrlr):
			self.invoker.inst().once(func():
				G.print("%s : %s" % [key, each])
				
				if key == "second" : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else : 
					ctrlr.next.call()
				
			, 1000),
		func():
			G.print("final")
	)


func test_each_list () :
	
	G.print("test : Uzil.Util.async.each")
	
	self.Util.async.each(
		["hello", "world", "godot"],
		func(idx, each, ctrlr):
			self.invoker.inst().once(func():
				G.print("%s : %s" % [idx, each])
				if idx == 1 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, 3000-(500*idx)),
		func():
			G.print("final here, should skip from 1")
	)

func test_each_dict () :
	
	G.print("test : Uzil.Util.async.each")
	
	var ref := {}
	ref.delay = 3000
	
	self.Util.async.each(
		{"first": "hello", "second": "world", "third": "godot"},
		func(key, each, ctrlr):
			ref.delay -= 500
			self.invoker.inst().once(func():
				G.print("%s : %s" % [key, each])
				if key == "second" : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, ref.delay),
		func():
			G.print("final here, should skip from second")
	)

func test_times_series () :
	
	G.print("test : Uzil.Util.async.times_series")
	
	self.Util.async.times_series(
		5,
		func(idx, ctrlr) :
			self.invoker.inst().once(func():
				G.print(idx)
				if idx == 2 : 
					ctrlr.skip.call()
#					ctrlr.stop.call()
#					ctrlr.next.call()
				else :
					ctrlr.next.call()
					
			, 3000),
		func():
			G.print("final")
	)

func test_times () :
	
	G.print("test : Uzil.Util.async.times")
	
	self.Util.async.times(
		5,
		func(idx, ctrlr):
			self.invoker.inst().once(func():
				G.print(idx)
				if idx == 2 : 
#					ctrlr.skip.call()
#					ctrlr.stop.call()
					ctrlr.next.call()
				else :
					ctrlr.next.call()
			, 2000),
		func():
			G.print("final")
	)
