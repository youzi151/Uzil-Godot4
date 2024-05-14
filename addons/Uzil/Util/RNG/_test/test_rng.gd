
# Variable ===================

var Uzil_RNG

# Extends ====================

func test_ready () :
	self.Uzil_RNG = UREQ.acc(&"Uzil:Util.RNG")
	
	var start_time
	var end_time
	
	start_time = Time.get_ticks_msec()
	self.test_normal()
	end_time = Time.get_ticks_msec()
	print("normal: %s ms" % (end_time - start_time))
	
	start_time = Time.get_ticks_msec()
	self.test_rate()
	end_time = Time.get_ticks_msec()
	print("rate: %s ms" % (end_time - start_time))
	
	start_time = Time.get_ticks_msec()
	self.test_pool()
	end_time = Time.get_ticks_msec()
	print("pool: %s ms" % (end_time - start_time))

func test_process (_delta) :
	pass


# Public =====================

func test_normal () :
	var rng = RandomNumberGenerator.new()
	for idx in range(100000) :
		var _num = rng.randi()
#		print(_num)
		

func test_rate () :
	var rng = self.Uzil_RNG.Rate.new().rates([4, 10, 5])
	for idx in range(100000) :
		var _num = rng.gen()
#		print("test: %s" % _num)

func test_pool () :
	print(self.Uzil_RNG.Pool.LoopType != null)
	var rng_pool = self.Uzil_RNG.Pool.new().minmax(2, 4).rates([6, 3, 1]).loop(self.Uzil_RNG.Pool.LoopType.SINGLE)
	
	var _last = null
	
	var statics = {}
	
	var msgs = []
	
	for idx in range(100000) :
		var res = rng_pool.next()
		
#		if res == _last :
#			msgs.push_back("repeat: %s" % res)
			
#		msgs.push_back("res======= %s" % res)
		
		var count = 1
		if statics.has(res) :
			count = statics[res] + 1
		statics[res] = count
		
		_last = res
	
	for msg in msgs :
		print(msg)
	
#	print(statics)
