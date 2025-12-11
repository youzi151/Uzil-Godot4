extends Node


# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 搜尋輸入
@export
var search_edit : LineEdit

## 成員容器
@export
var member_container : Node

## 成員預製物件
@export
var member_prefab : Node

var UTQ : Node = null
var utq_inst = null

var target_to_content := {}

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_utq")
	
	var root_node : Node = self.get_tree().root
	if root_node.has_node("UREQ") :
		self.UTQ = root_node.get_node("UREQ").acc(&"UTQ")
	else :
		self.UTQ = G.load_script("res://addons/utq/scripts/utq.gd").new()
		root_node.add_child.call_deferred(self.UTQ)
		
		await self.UTQ.tree_entered
	
	# 實例
	self.utq_inst = self.UTQ.inst()
	self.utq_inst.is_debug = false
	
	
	# 註冊 當 搜尋列 送出
	self.search_edit.text_submitted.connect(func(txt):
		self.test_search()
	)
	self.search_edit.text = "all +[series:S1, A2] even"
	
	# 成員列表 容器
	# 成員 預製
	self.member_prefab.visible = false
	
	# 建立數個成員
	for idx in 3 :
		
		var idx_str = str(idx)
		
		# 建立成員
		var member_node = self.member_prefab.duplicate()
		self.member_container.add_child(member_node)
		member_node.visible = true
		
		# 內容編輯列
		var content_edit : LineEdit = member_node.get_node("HBoxContainer/TargetEdit")
		content_edit.text = "content_%s" % idx_str
		content_edit.text_changed.connect(func(txt):
			self.target_to_content[idx_str] = content_edit.text
		)
		self.target_to_content[idx_str] = content_edit.text
		
		# 標籤編輯列
		var tags_edit : LineEdit = member_node.get_node("HBoxContainer/TagEdit")
		
		# 基數偶數
		var odd_or_even := "odd"
		if (idx % 2) == 0 :
			odd_or_even = "even"
		
		# 全部, 系列:S1~S3, 基數偶數
		tags_edit.text = "all series:S%s, A%s %s" % [idx_str, idx_str, odd_or_even]
		
		# 當 標籤編輯列 送出
		tags_edit.text_changed.connect(func(txt):
			self.utq_inst.set_data(idx_str, [tags_edit.text])
		)
		
		# 設置標籤
		self.utq_inst.set_data(idx_str, [tags_edit.text])
		
	

func _process (_delta) :
	pass

func _exit_tree () :
	G.off_print("test_utq")

# Extends ====================

# Public =====================

func test_search () :
	
	G.print("== test_search ========")
	
	# 取得 搜尋列文字
	var to_search : String = self.search_edit.text
	
	# 試著解析 搜尋列資料
	var search_request = self.utq_inst.executor.parse_search_str(to_search)
	var parsed_search_msg : String = "parsed search request :"
	for each in search_request :
		parsed_search_msg += "\n%s" % [each]
		if each[0] == "s" :
			parsed_search_msg += "\n%s" % [self.utq_inst.queryer.parse_tags_str(each[1])]
	G.print(parsed_search_msg)
	
	# 搜尋目標
	var results : Array = self.utq_inst.search(to_search).keys()
	
	# 以目標找出對應內容
	var contents : Array = []
	for each in results :
		if not self.target_to_content.has(each) : continue
		contents.push_back(self.target_to_content[each])
	
	G.print("== search results ===")
	G.print(contents)
	G.print("=======================")

func test_simple () :
	
	G.print("== test_simple ========")
	
	# 實例
	var inst = self.UTQ.inst("test_simple")
	
	# 搜尋文字
	var search_str := ' -gender:male role : tank, "super tank", dps (test, test2) '
	G.print("parse : %s" % search_str)
	
	# 試解析搜尋資料
	var parsed_tags = inst.queryer.parse_tags_str(search_str)
	G.print(parsed_tags)
	G.print("=========")
	
	# 設置 成員內容 (以字串)
	inst.set_data("Aman", ["role:dps","gender:male"])
	inst.set_data("Bwoman", ["role:tank","gender:female"])
	
	# 設置 成員內容 (以資料)
	var c_man_tag_datas := []
	var c_man_tag_data_1 = self.UTQ.tag()
	c_man_tag_data_1.scope = "role"
	c_man_tag_data_1.val = "sup"
	var c_man_tag_data_2 = self.UTQ.tag()
	c_man_tag_data_2.scope = "gender"
	c_man_tag_data_2.val = "male"
	inst.set_data("Cman", [c_man_tag_data_1, c_man_tag_data_2])
	
	inst.set_data("Dman", ["role:sup,tank","gender:male"])
	
	# 搜尋
	G.print(inst.search("-role:dps gender:male").keys())
	G.print(inst.search("role:sup - role : tank").keys())
	
	G.print("=======================")


func test_performance () :
	var inst = self.UTQ.once()
	
	var data_size := 100
	for idx in data_size :
		inst.set_data("axe_%02d" % [idx+1], ["type:axe", "class:dps", "attr:phys"])
	for idx in data_size :
		inst.set_data("mace_%02d" % [idx+1], ["type:mace", "class:dps", "attr:phys"])
	for idx in data_size :
		inst.set_data("staff_%02d" % [idx+1], ["type:staff", "class:sup", "attr:mage"])
	for idx in data_size :
		inst.set_data("sheild_%02d" % [idx+1], ["type:sheild", "class:tank", "attr:mage"])
	
	var search_str := "attr:phys & (type:noexist > (class:dps | attr:mage) > type:noexist % [type:sheild])"
	#print(inst.search(search_str))
	#print(self.utq_inst.get_datas())
	var start : int = Time.get_ticks_usec()
	for idx in 100 :
		inst.search(search_str)
	G.print(Time.get_ticks_usec() - start)
	

func test_scenario () :
	var inst = self.UTQ.once()
	
	#G.print(inst.queryer.parse_tags_str("@/類型:物理 !/材質:測試 稀有度:無 可附魔:.^火"))
	
	# === 武器系統 ===
	# 單手武器
	inst.set_data("鐵劍(火球術)", [
		"類型:物理",
		"類型:劍",
		"材質:金屬",
		"稀有度:常見",
		"需求:力量",
		"重量:中",
		"範圍:近",
		"附魔:火球術",
	])
	
	inst.set_data("鐵斧", [
		"類型:物理",
		"類型:斧",
		"材質:金屬",
		"稀有度:常見",
		"需求:力量",
		"重量:中",
		"範圍:近",
	])
	
	inst.set_data("雷錘", [
		"類型:武器",
		"類型:錘",
		"材質:金屬",
		"稀有度:稀有",
		"需求:敏捷",
		"重量:重",
		"範圍:近",
		"範圍:遠",
		"屬性:聖",
		"屬性:雷",
	])
	
	# 雙手武器
	inst.set_data("冰霜大劍", [
		"類型:物理",
		"類型:劍",
		"類型:大劍",
		"材質:金屬",
		"稀有度:稀有",
		"需求:力量",
		"重量:重",
		"範圍:近",
		"屬性:冰",
	])
	
	# 魔法武器
	inst.set_data("火掌", [
		"類型:魔法",
		"類型:拳掌",
		"材質:皮革",
		"稀有度:稀有",
		"需求:智力",
		"重量:輕",
		"範圍:近",
		"屬性:火"
	])
	
	inst.set_data("火焰杖", [
		"類型:魔法",
		"類型:杖",
		"材質:木頭",
		"材質:紅寶石",
		"稀有度:稀有",
		"需求:智力",
		"重量:輕",
		"範圍:遠",
		"屬性:火"
	])
	
	inst.set_data("冰霜杖", [
		"類型:魔法",
		"類型:杖",
		"材質:木頭",
		"材質:藍寶石",
		"稀有度:稀有",
		"需求:智力",
		"重量:中",
		"範圍:遠",
		"屬性:冰"
	])

	
	# 遠程武器
	inst.set_data("長弓", [
		"類型:物理",
		"類型:弓",
		"材質:木頭",
		"稀有度:常見",
		"需求:敏捷",
		"重量:中",
		"範圍:遠",
	])
	
	inst.set_data("聖火弩", [
		"類型:物理",
		"類型:弩",
		"材質:木頭",
		"材質:金屬",
		"稀有度:稀有",
		"需求:敏捷",
		"重量:重",
		"範圍:遠",
		"屬性:聖",
		"屬性:火",
	])
	
	
	# === 執行測試查詢 ===
	G.print("\n=== 基礎查詢測試 ===")
	
	# 使用 標籤 查找劍武器
	G.print("\n* 劍類武器:")
	G.print(inst.search("+類型:劍").keys())
	
	# 使用 群組標籤 查找劍或斧類武器
	G.print("\n* 劍或斧類武器:")
	G.print(inst.search("+[類型:劍, 斧]").keys())
	
	# 使用 標籤 與 群組標籤 查找火系或冰系法術武器
	G.print("\n* 冰或火魔法武器:")
	G.print(inst.search("類型:魔法 +[屬性:火, 冰]").keys())
	
	# 使用 萬用標籤 與 排除標籤 與 除例外之萬用字元 查找 有屬性 但 沒有除火屬性以外其他屬性的武器
	G.print("\n* 有屬性 但 沒有除火屬性以外其他屬性的:")
	G.print(inst.search("屬性:. -屬性:.^火").keys())
	
	# 使用 排除標籤 與 寬容標籤 與 絕對標籤 查找 除了聖屬性以外 非物理 或 有任意附魔的武器
	G.print("\n* 除了聖屬性以外 非物理的稀有武器 或 任意附魔:")
	G.print(inst.search("稀有度:稀有 -類型:物理 *附魔:. --屬性:聖").keys())
	
	G.print("\n=== 進階查詢測試 ===")
	
	# 後備查詢：優先找稀有武器，否則找普通武器
	G.print("\n* 優先找稀有武器，否則找普通武器:")
	G.print(inst.search("稀有度:神話 > 稀有度:稀有 > 稀有度:常見").keys())
	
	# 對稱差查詢：查找 所有非冰遠程或火近戰的武器
	G.print("\n* 所有非冰遠程或火近戰的武器:")
	G.print(inst.search(". % (屬性:冰 範圍:遠 | 屬性:火 範圍:近)").keys())
	
	# 複合查詢：查找 所有非冰遠程或火近戰的武器
	G.print("\n* 對抗不死生物需要(屬性近武 或 聖屬遠/魔武), 查詢無法對抗的:")
	G.print(inst.search(". % (屬性:. 範圍:近 | (屬性:聖 & *範圍:遠 *類型:魔法)").keys())
