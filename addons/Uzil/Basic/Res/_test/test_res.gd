extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_res")

func _exit_tree () :
	G.off_print("test_res")

# Extends ====================

# Interface ==================

# Public =====================

func test_simple () :
	var Res = UREQ.acc(&"Uzil:Basic.Res")
	var res_mgr = UREQ.acc(&"Uzil:res_mgr")
	var Res_FIEL_PATH = Res.PATH.replace("res://", "file://")
	
	res_mgr.is_debug = true
	res_mgr.built_in_loader.is_debug = true
	
	var is_success = await res_mgr.prehold_preset(Res_FIEL_PATH.path_join("_test/test_res_preset_target.json"))
	G.print("prehold result : %s" % is_success)
	
	var res_target = await res_mgr.hold(Res_FIEL_PATH.path_join("_test/res/res_target.txt"))
	G.print(res_target.res)
	
	var res_base = await res_mgr.hold(Res_FIEL_PATH.path_join("_test/res/res_base.txt"))
	G.print(res_base.res)
	
	G.print("res_target is alive %s" % res_target.is_alive())
	G.print("res_base is alive %s" % res_base.is_alive())
	G.print("res_base cached : %s" % ResourceLoader.has_cached("res://addons/URes/_test/res/res_base.txt"))
	
	res_mgr.unprehold_preset(Res_FIEL_PATH.path_join("_test/test_res_preset_target.json"))
	
	
	G.print("res_target is alive %s by %s" % [res_target.is_alive(), res_target.holders])
	G.print("res_base is alive %s by %s" % [res_base.is_alive(), res_base.holders])
	G.print("res_base cached : %s" % ResourceLoader.has_cached("res://addons/URes/_test/res/res_base.txt"))
	
	res_base = await res_mgr.hold(Res_FIEL_PATH.path_join("_test/res/res_base.txt"))
	
	

# Private ====================

