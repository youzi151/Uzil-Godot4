extends Node


# Variable ===================

## 幀錯文字
@export
var debug_label : TextEdit

## 搜尋輸入
@export
var search_edit : LineEdit

## 成員容器
@export
var member_container : Node

## 成員預製物件
@export
var member_prefab : Node

var TagQ = null
var tag_q = null

var target_to_content := {}

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_label.text += msg+"\n"
	, "test_tag_q")
	
	self.TagQ = UREQ.acc("Uzil", "Basic.TagQ")
	
	# 實例
	self.tag_q = UREQ.acc("Uzil", "tag_q").inst("test")
	
	# 註冊 當 搜尋列 送出
	self.search_edit.text_submitted.connect(func(txt):
		self.test_search()
	)
	self.search_edit.text = "all +series:S1, A2 even"
	
	# 成員列表 容器
	# 成員 預製
	self.member_prefab.visible = false
	
	# 建立數個成員
	for idx in range(3) :
		
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
			self.tag_q.set_tags(idx_str, [tags_edit.text])
		)
		
		# 設置標籤
		self.tag_q.set_tags(idx_str, [tags_edit.text])
		
	

func _process (_delta) :
	pass

func _exit_tree () :
	G.off_print("test_tag_q")

# Extends ====================

# Public =====================

func test_search () :
	
	G.print("== test_search ========")
	
	# 取得 搜尋列文字
	var to_search : String = self.search_edit.text
	
	# 試著解析 搜尋列資料
	var search_data = self.tag_q.parse_search_str(to_search)
	G.print("parsed tags : \n" + str(search_data.tags))
	
	# 搜尋目標
	var results : Array = self.tag_q.search(to_search)
	
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
	var tag_q = UREQ.acc("Uzil", "tag_q")
	
	# 實例
	var inst = tag_q.inst("test_simple")
	
	# 搜尋文字
	var search_str := ' -gender:male role : tank, "super tank", dps (test, test2) '
	G.print("parse : %s" % search_str)
	
	# 試解析搜尋資料
	var search_data = inst.parse_search_str(search_str)
	for each in search_data.tags :
		G.print(each)
	G.print("=========")
	
	# 設置 成員內容 (以字串)
	inst.set_tags("Aman", ["role:dps","gender:male"])
	inst.set_tags("Bwoman", ["role:tank","gender:female"])
	
	# 設置 成員內容 (以資料)
	var c_man_tag_datas := []
	var c_man_tag_data_1 = self.TagQ.TagData.new()
	c_man_tag_data_1.scope = "role"
	c_man_tag_data_1.id = "sup"
	var c_man_tag_data_2 = self.TagQ.TagData.new()
	c_man_tag_data_2.scope = "gender"
	c_man_tag_data_2.id = "male"
	inst.set_datas("Cman", [c_man_tag_data_1, c_man_tag_data_2])
	
	inst.set_tags("Dman", ["role:sup,tank","gender:male"])
	
	# 搜尋
	G.print(inst.search("-role:dps gender:male"))
	G.print(inst.search("role:sup - role : tank"))

	G.print("=======================")
