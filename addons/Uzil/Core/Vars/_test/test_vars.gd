extends Node

# Variable ===================

@export
var debug_label : TextEdit

# Extends ====================

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_label.text += msg+"\n"
	, "test_vars")

func _exit_tree () :
	G.off_print("test_vars")

# Public =====================

func test_normal () :
	
	var Vars = UREQ.acc("Uzil", "vars_mgr")
	
	# 建立 變數集
	var vars = Vars.inst()
	
	# 偵聽 當 變數改變
	var listener1 = vars.on_var_changed(func(ctrlr):
		var data = ctrlr.data
		var msg : String = "on_var_changed : var[\"%s\"] set " % data.key
		
		if data.has("last") :
			msg += "from %s " % data["last"]
		
		msg += " to %s" % data["val"]
		
		G.print(msg)
	)
	
	
	# 設置 變數
	G.print("set var1 : test")
	vars.set_var("var1", "test")
	
	# 取得 變數 並 印出
	G.print("get var1 : %s" % vars.get_var("var1"))
	
	# 設置 變數 為 空
	G.print("set var1 : <null>")
	vars.set_var("var1", null)
	# 取得 變數 並 印出
	G.print("get var1 : %s" % vars.get_var("var1"))
	
	# 註銷 偵聽
	vars.off_var_changed(listener1)
	G.print("off_var_changed")
	
	# 設置 變數
	G.print("set var1 : final")
	vars.set_var("var1", "final")
	
	# 取得 變數 並 印出
	G.print("get var1 : %s" % vars.get_var("var1"))
