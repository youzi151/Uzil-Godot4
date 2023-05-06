extends Uzil_Test_Base

# Variable ===================

var obj_alives := 0

# Extends ====================

func test_ready () :
	self.test()

func test_process (_delta) :
	pass


# Public =====================

func test () :
	
	# 建立物件池
	var pool = G.v.Uzil.Core.ObjPool.Core_Any.new_shell()
	pool.set_size(5)
	pool.core.set_create(func():
		self.obj_alives += 1
		print("costtime")
		var new_one = {}
		new_one.msg = "hide"
		return new_one
	)
	pool.core.set_destroy(func(old_one):
		old_one.msg = null
		self.obj_alives -= 1
		print("destory")
	)
	pool.core.set_init(func(new_one):
		new_one.msg = "show"
	)
	pool.core.set_uninit(func(old_one):
		old_one.msg = "hide"
	)
	
	# 重置尺寸
	print("resize start")
	
	pool.resize()
	
	print("resize end obj alives : %s" % self.obj_alives)
	
	# 開始取用
	print("reuse start :")
	var reuses = []
	for idx in range(7) :
		var each = pool.reuse()
		print("%s : %s" % [idx, each.msg])
		each.msg = "changed"
		reuses.push_back(each)
	print("reuse end")
	
	# 開始回收
	print("recovery start :")	
	for idx in range(reuses.size()) :
		var each = reuses[idx]
		pool.recovery(each)
		print("%s : %s" % [idx, each.msg])
	
	print("recovery end. obj alive = %s" % self.obj_alives)	
	
	# 重設尺寸
	pool.set_size(0)
	
	# 重置尺寸
	pool.resize()
	
	print("resize. obj alive = %s" % self.obj_alives)	
