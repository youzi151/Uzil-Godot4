extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

var Uzil_RNG

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_rng")
	
	self.Uzil_RNG = UREQ.acc(&"Uzil:Util.RNG")

func _exit_tree () :
	G.off_print("test_rng")

# Extends ====================

# Public =====================

func test_all () :
	var start_time
	var end_time
	
	var times := 10000
	
	start_time = Time.get_ticks_msec()
	self.test_normal(times, false)
	end_time = Time.get_ticks_msec()
	G.print("normal: %s ms" % (end_time - start_time))
	
	start_time = Time.get_ticks_msec()
	self.test_rate(times, false)
	end_time = Time.get_ticks_msec()
	G.print("rate: %s ms" % (end_time - start_time))
	
	start_time = Time.get_ticks_msec()
	self.test_pool(times, false)
	end_time = Time.get_ticks_msec()
	G.print("pool: %s ms" % (end_time - start_time))

func test_normal (times: int = 1, is_log := true) :
	var rng = RandomNumberGenerator.new()
	for idx in range(times) :
		var _num = rng.randi()
		if is_log :
			G.print("RNG normal : %s" % _num)
		

func test_rate (times: int = 1, is_log := true) :
	var rng = self.Uzil_RNG.Rate.new().rates([4, 10, 5, -20])
	for idx in range(times) :
		var _num = rng.gen()
		if is_log :
			G.print("RNG rate : %s" % _num)

func test_pool (times: int = 1, is_log := true) :
	G.print(self.Uzil_RNG.Pool.LoopType != null)
	var rng_pool = self.Uzil_RNG.Pool.new().minmax(2, 4).rates([6, 3, 1]).loop(self.Uzil_RNG.Pool.LoopType.SINGLE)
	
	var _last = null
	
	var statics = {}
	
	var msgs = []
	
	for idx in range(times) :
		var res = rng_pool.next()
		
		if is_log :
			if res == _last :
				msgs.push_back("repeat: %s" % res)
			msgs.push_back("res======= %s" % res)
		
		var count = 1
		if statics.has(res) :
			count = statics[res] + 1
		statics[res] = count
		
		_last = res
	
	if is_log :
		for msg in msgs :
			G.print(msg)
