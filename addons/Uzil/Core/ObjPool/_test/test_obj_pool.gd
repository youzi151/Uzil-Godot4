extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

var obj_alives := 0

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_obj_pool")

func _process (_delta) :
	pass

func _exit_tree () :
	G.off_print("test_obj_pool")

# Extends ====================

# Public =====================

func test_normal () :
	
	var ObjPool = UREQ.acc("Uzil", "ObjPool")
	
	# 建立物件池
	var pool = ObjPool.Strat_Any.new_core()
	pool.strat.set_create(func():
		self.obj_alives += 1
		G.print("create obj (strategy)")
		var new_one = {}
		new_one.msg = "hide"
		return new_one
	)
	pool.strat.set_destroy(func(old_one):
		old_one.msg = null
		self.obj_alives -= 1
		G.print("destroy obj (strategy)")
	)
	pool.strat.set_init(func(new_one, _data):
		new_one.msg = "state : initialized"
	)
	pool.strat.set_uninit(func(old_one):
		old_one.msg = "state : uninitialized"
	)
	
	# 重置尺寸
	pool.set_size(5)
	G.print("pool resize start")
	pool.resize()
	
	G.print("pool resized, obj alives : %s" % self.obj_alives)
	
	# 開始取用
	G.print("reuse start :")
	var reuses = []
	for idx in range(7) :
		var each = pool.reuse()
		G.print("reused : %s, %s" % [idx+1, each.msg])
		reuses.push_back(each)
	G.print("reuse end")
	
	# 開始回收
	G.print("recovery start :")	
	for idx in range(reuses.size()) :
		var each = reuses[idx]
		pool.recovery(each)
		G.print("recovery : %s, %s" % [idx+1, each.msg])
	
	G.print("recovery end. obj alive = %s" % self.obj_alives)	
	
	# 重設尺寸
	pool.set_size(0)
	
	# 重置尺寸
	G.print("pool resize 0 start")
	pool.resize()
	
	G.print("pool resized. obj alive = %s" % self.obj_alives)	
