extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 使用者 項目 預製
@export
var user_item_prefab : Node
## 使用者 項目 容器
@export
var user_item_container : Node

## 修改器 訊息 編輯
@export
var modifier_message_edit : Node
## 過濾標籤 編輯
@export
var filter_tags_edit : Node

## 當前數值 文字
@export
var current_val_label : Node

## 多重數值
var vals

## 修改訊息
var modify_msg : String

# Extends ====================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_vals")
	
	# 引用 類腳本
	var Vals = UREQ.acc(&"Uzil:Core.Vals")
	
	# 建立 多重數值
	self.vals = Vals.new()
	
	# 建立 使用者 與 測試用面板
	for idx in range(3) :
		
		var new_one = self.user_item_prefab.duplicate()
		self.user_item_container.add_child(new_one)
		new_one.visible = true
		
		new_one.get_node("HBoxContainer/User").text = "[b]User : %s[/b]" % idx
		
		var value_text_edit : LineEdit = new_one.get_node("HBoxContainer/ValueEdit")
		var priority_text_edit : LineEdit = new_one.get_node("HBoxContainer/PriorityEdit")
		var tag_text_edit : LineEdit = new_one.get_node("HBoxContainer/TagEdit")
		
		var vals_user : String = "user_%s" % idx
		
		# 設置 多重數值 使用者
		# 初始數值 與 優先度
		var init_val : String = "State_%s" % idx
		var init_pri : int = idx
		self.vals.set_data(vals_user, init_val, init_pri) 
		
		# 數值 面板
		value_text_edit.text = init_val
		# 當 數值面板 更動 時
		value_text_edit.text_changed.connect(func(txt):
			# 設置 該多重數值使用者 數值
			self.vals.set_val(vals_user, value_text_edit.text)
		)
		
		# 標籤 面板
		tag_text_edit.text = ""
		# 當 標籤面板 更動 時
		tag_text_edit.text_changed.connect(func(txt):
			var tags := []
			var splited = tag_text_edit.text.split(",")
			for each in splited :
				tags.push_back(each.replace(" ", ""))
			# 設置 標籤
			self.vals.set_tags(vals_user, tags)
		)
		
		# 優先度 面板
		priority_text_edit.text = str(init_pri)
		# 當 優先度面板 更動 時
		priority_text_edit.text_changed.connect(func(txt):
			if not priority_text_edit.text.is_valid_int() : return
			# 設置 該多重數值使用者 優先度
			self.vals.set_pri(vals_user, priority_text_edit.text.to_int())
		)
	
	# 設置 當前數值標籤 為 當前數值
	self.current_val_label.text = self.vals.current()
	
	# 註冊 當 更新
	self.vals.on_update.on(func(ctrlr):
		var txt : String = str(self.vals.current())
		G.print("on update to : %s " % txt)
		self.current_val_label.text = txt
	)
	
	# 設置 修改器行為
	var set_modifier := func(txt) :
		self.modify_msg = txt
		
		# 設置 修改內容 行為
		self.vals.set_current_modifier_fn(func(data):
			var str = str(data.val)
			if not self.modify_msg.is_empty() :
				str += "_%s" % self.modify_msg
			return str
		)
	set_modifier.call("")
	# 設置 當 修改器面板 更動時
	self.modifier_message_edit.text_changed.connect(set_modifier)
	
	# 設置 當 過濾標籤 更動時
	self.filter_tags_edit.text_changed.connect(func(txt):
		var filters := []
		var splited = txt.split(",")
		for each in splited :
			var aa = each.replace(" ", "")
			filters.push_back(aa)
		# 設置 過濾標籤
		self.vals.set_filters(filters)
	)
	
	
	G.print("vals current : %s " % self.vals.current())

func _process (_delta) :
	pass
	
func _exit_tree () :
	G.off_print("test_vals")


# Public =====================

func test_simple () :
	G.print("== test_simple ===========")
	
	var Vals = UREQ.acc(&"Uzil:Core.Vals")
	
	var vals = Vals.new()
	
	# 設置 預設值
	vals.set_default("null (default)")
	
	# 設置 修改器
	vals.set_current_modifier_fn(func(data):
		return "%s + overwrite" % data.val
	)
	
	# 當 數值更新
	vals.on_update.on(func(ctrlr):
		G.print("on update to : %s " % vals.current())
	)
	
	# 設置 基本
	G.print("set_data usr_system : sys : 2 ")
	vals.set_data("usr_system", "sys", 2)
	G.print("set_data usr_functional : func : 3")
	vals.set_data("usr_functional", "func", 3)
	
	# 改寫 值
	G.print("set_val usr_system : sys2")
	vals.set_val("usr_system", "sys2")
	G.print("set_val usr_system : func2")
	vals.set_val("usr_functional", "func2")
	
	# 改寫 優先度
	G.print("set_pri usr_system : 5")
	vals.set_pri("usr_system", 5)
	
	# 取得 當前值
	G.print("final : %s " % vals.current())
