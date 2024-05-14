extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export var opt_root : Node

@export var opt_1 : Node
@export var opt_1_1 : Node
@export var opt_1_2 : Node

@export var opt_2 : Node
@export var opt_2_1 : Node
@export var opt_2_2 : Node


var SumVals

var sum_vals

# GDScript ===================


func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_sum_vals")
	
	self.SumVals = UREQ.acc(&"Uzil:Core.SumVals")
	
	self.sum_vals = self.SumVals.Inst.new()
	self.sum_vals.set_default(0)
	self.sum_vals.set_summary_val_fn(func(val, sub_vals):
		var sum = val
		for each in sub_vals :
			sum += each
		return sum
	)
	
	self.sum_vals.on_update(null, func(ctrlr):
		G.print(ctrlr.data)
		self.opt_root.get_node("HBoxContainer/SumTxt").text = "[b]Sum (%s)[/b]" % ctrlr.data
	)
	
	# OPT 1 ###############
	var opt_1_route := "1"
	self.sum_vals.on_update(opt_1_route, func(ctrlr):
		self.opt_1.get_node("HBoxContainer/SumTxt").text = "[b]Sum (%s)[/b]" % ctrlr.data
	)
	var opt_1_self_val : LineEdit = self.opt_1.get_node("HBoxContainer/SelfVal")
	opt_1_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_1_route, txt.to_float())
	)
	opt_1_self_val.text = "10"
	self.sum_vals.set_val(opt_1_route, opt_1_self_val.text.to_float(), false)
	
	# OPT 1.1 #####
	var opt_1_1_route := "1.1" 
	var opt_1_1_self_val : LineEdit = self.opt_1_1.get_node("HBoxContainer/SelfVal")
	opt_1_1_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_1_1_route, txt.to_float())
	)
	opt_1_1_self_val.text = "1"
	self.sum_vals.set_val(opt_1_1_route, opt_1_1_self_val.text.to_float(), false)
	
	# OPT 1.2 #####
	var opt_1_2_route := "1.2" 
	var opt_1_2_self_val : LineEdit = self.opt_1_2.get_node("HBoxContainer/SelfVal")
	opt_1_2_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_1_2_route, txt.to_float())
	)
	opt_1_2_self_val.text = "2"
	self.sum_vals.set_val(opt_1_2_route, opt_1_2_self_val.text.to_float(), false)
	
	# OPT 2 ###############
	var opt_2_route := "2" 
	self.sum_vals.on_update(opt_2_route, func(ctrlr):
		self.opt_2.get_node("HBoxContainer/SumTxt").text = "[b]Sum (%s)[/b]" % ctrlr.data
	)
	var opt_2_self_val : LineEdit = self.opt_2.get_node("HBoxContainer/SelfVal")
	opt_2_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_2_route, txt.to_float())
	)
	opt_2_self_val.text = "20"
	self.sum_vals.set_val(opt_2_route, opt_2_self_val.text.to_float(), false)
	
	# OPT 2.1 #####
	var opt_2_1_route := "2.1" 
	var opt_2_1_self_val : LineEdit = self.opt_2_1.get_node("HBoxContainer/SelfVal")
	opt_2_1_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_2_1_route, txt.to_float())
	)
	opt_2_1_self_val.text = "3"
	self.sum_vals.set_val(opt_2_1_route, opt_2_1_self_val.text.to_float(), false)
	
	# OPT 2.2 #####
	var opt_2_2_route := "2.2" 
	var opt_2_2_self_val : LineEdit = self.opt_2_2.get_node("HBoxContainer/SelfVal")
	opt_2_2_self_val.text_changed.connect(func(txt: String):
		if not txt.is_valid_float() : return
		self.sum_vals.set_val(opt_2_2_route, txt.to_float())
	)
	opt_2_2_self_val.text = "4"
	self.sum_vals.set_val(opt_2_2_route, opt_2_2_self_val.text.to_float(), false)
	
	self.sum_vals.update()

func _process (_delta) :
	pass

func _exit_tree () :
	G.off_print("test_sum_vals")

# Extends ====================

# Public =====================

func test_simple () :
	
	G.print("== test_simple ===========")
	
	var sum_vals = self.SumVals.Inst.new()
	
	# 註冊 當 通知:信件.公會 更新
	sum_vals.on_update("mail.guild", func(ctrlr):
		G.print("on update mail.guild to : %s " % ctrlr.data)
	)
	# 註冊 當 通知:信件 更新
	sum_vals.on_update("mail", func(ctrlr):
		G.print("on update mail to : %s " % ctrlr.data)
	)
	
	# 設置 加總值 方式
	sum_vals.set_summary_val_fn(func(val, sub_vals) :
		var total = 0
		if val != null :
			total += val
		for each in sub_vals :
			total += each
		return total
	)
	
	# 設置 結果修改器
	sum_vals.set_result_modifier_fn(func(val):
		return "%s + overwrite" % val
	)
	
	# 設置 預設 值
	sum_vals.set_default(0)
	
	# 設置 通知:信件.好友.送禮 (不更新)
	G.print("set mail.friend.gift (don't update)")
	sum_vals.set_val("mail.friend.gift", 100, false)
	# 設置 通知:信件.公會.公會戰 (不更新)
	G.print("set mail.guild.war (don't update)")
	sum_vals.set_val("mail.guild.war", 1, false)
	# 設置 通知:信件.公會.發薪 (不更新)
	G.print("set mail.guild.salary (don't update)")
	sum_vals.set_val("mail.guild.salary", 0, false)
	
	G.print("manual update")
	sum_vals.update()
	
	# 設置 通知:信件.公會.發薪
	G.print("set mail.guild.salary")
	sum_vals.set_val("mail.guild.salary", 7)
	# 設置 通知:信件.公會.發薪.獎勵
	G.print("set mail.guild.salary.bonus")
	sum_vals.set_val("mail.guild.salary.bonus", 10)
	
	# 移除 路由 通知:信件.公會.公會戰
	G.print("del mail.guild.salary.war")
	sum_vals.del_route("mail.guild.war")
	# 移除 路由 通知:信件.公會.不存在的key
	sum_vals.del_route("mail.guild.war.notexistkey")
	
	# 印出 最終通知數
	G.print("final mail box hint : %s " % sum_vals.get_sum_val("mail"))
	
	
