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
	
	self.invoker = UREQ.acc(&"Uzil:invoker_mgr")
	self.Util = UREQ.acc(&"Uzil:Util")

func _exit_tree () :
	G.off_print("test_async")


# Extends ====================

# Public =====================

func test_waterfall () :
	
	G.print("test : Uzil.Util.async.waterfall")
	
	await self.Util.async.waterfall(
		[
			func(ctrlr):
				G.print("A")
				ctrlr.next(),
			func(ctrlr):
				G.print("B")
				self.invoker.inst().once(func():
					ctrlr.next()
				, 1000),
			func(ctrlr):
				G.print("C")
#				ctrlr.stop()
				ctrlr.skip()
				,
			func(ctrlr):
				G.print("D")
				ctrlr.next(),
		],
	)
	G.print("final")

func test_parallel () :
	
	G.print("test : Uzil.Util.async.parallel")
	
	await self.Util.async.parallel([
		func(ctrlr):
			G.print("A")
			ctrlr.next()
			# ctrlr.skip()
			,
		func(ctrlr):
			self.invoker.inst().once(func():
				G.print("B")
				ctrlr.next()
			, 1000)
			,
		func(ctrlr):
			G.print("C")
			ctrlr.next()
			# ctrlr.stop()
			,
	])
	G.print("final")

func test_each_series_list () :
	
	G.print("test : Uzil.Util.async.each_series")
	
	await self.Util.async.each_series(
		["hello", "world", "godot"],
		func(idx, each, ctrlr):
			self.invoker.inst().once(func():
				G.print("%s : %s" % [idx, each])
				
				if idx == 1 : 
					ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
				else : 
					ctrlr.next()
				
			, 3000-(500*idx))
			,
	)
	G.print("after await, should skip from 1.")
	
func test_each_series_dict () :
	
	G.print("test : Uzil.Util.async.each_series")
	
	await self.Util.async.each_series(
		{"first": "hello", "second": "world", "third": "godot"},
		func(key, each, ctrlr):
			self.invoker.inst().once(func():
				G.print("%s : %s" % [key, each])
					
				if key == "second" : 
					ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
				else : 
						ctrlr.next()
			, 1000)
			,
		{
			"on_done" : func():
				G.print("on_done in options, should skip from second.")
				,
		}
	)
	G.print("after await, should skip from second.")


func test_each_list () :
	
	G.print("test : Uzil.Util.async.each")
	
	await self.Util.async.each(
		["hello", "world", "godot"],
		func(idx, each, ctrlr):
			self.invoker.inst().once(func():
				G.print("%s : %s" % [idx, each])
				
				if idx == 1 : 
					ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
				else : 
					ctrlr.next()
				
			, 3000-(500*idx))
			,
		{
			"on_done" : func():
				G.print("on_done in options, should skip from 1.")
				,
		}
	)
	G.print("after await, should skip from 1.")
	G.print("0 still be execute because it won't wait and not execute until 1's next called.")

func test_each_dict () :
	
	G.print("test : Uzil.Util.async.each")
	
	var ref := {}
	ref.delay = 3000
	
	await self.Util.async.each(
		{"first": "hello", "second": "world", "third": "godot"},
		func(key, each, ctrlr):
			G.print("%s : %s" % [key, each])
			if key == "second" : 
				ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
			else :
				ctrlr.next()
			,
		{
			"on_done" : func():
				G.print("on_done in options, should skip from second.")
				,
		}
	)
	G.print("after await, should skip from second.")

func test_times_series () :
	
	G.print("test : Uzil.Util.async.times_series")
	
	await self.Util.async.times_series(
		5,
		func(idx, ctrlr) :
			self.invoker.inst().once(func():
				G.print(idx)
				if idx == 2 : 
					ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
				else :
					ctrlr.next()
					
			, 3000)
			,
	)
	G.print("final")

func test_times () :
	
	G.print("test : Uzil.Util.async.times")
	
	await self.Util.async.times(
		5,
		func(idx, ctrlr):
			self.invoker.inst().once(func():
				G.print(idx)
				if idx == 2 : 
					ctrlr.skip()
#					ctrlr.stop()
#					ctrlr.next()
				else :
					ctrlr.next()
			, 2000),
	)
	G.print("final")
