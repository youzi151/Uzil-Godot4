extends Node

## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

# Variable ===================

## 辨識
@export
var id : String = ""

## 基底查詢內容
@export_multiline
var base_query : String = ""

## 預設組合
@export
var default_combo_node : Node = null

## 組合:查詢串 表 String:String
@export
var combo_nodes : Array[Node] = []

## 卡片
@export
var card_ids : Array[String] = []
@export
var card_nodes : Array[Node] = []

## 頁面
var page = null

# GDScript ===================

# Public =====================

func request_page (page_card_inst = null) :
	
	if self.page != null : return self.page
	
	self.page = UREQ.acc("Uzil", "Advance.PageCard").Page.new()
	
	if self.id.is_empty() :
		self.page.id = self.name
	else :
		self.page.id = self.id
	
	if not self.base_query.is_empty() :
		self.page.base_query = self.base_query
	
	# 組合 與 查詢字串
	var combo_to_query_str := {}
	# 來源 : 組合節點
	for each in self.combo_nodes :
		if not each.has_method("request_combo") : continue
		var combo_data : Dictionary = each.request_combo()
		combo_to_query_str[combo_data.id] = combo_data.query_str
	# 來源 : 字典
	# 設置 組合
	for id in combo_to_query_str :
		self.page.set_combo(id, combo_to_query_str[id])
	
	# 預設 組合
	if self.default_combo_node != null :
		self.page.default_combo = self.default_combo_node.request_combo().id
	
	# 卡片
	var to_add_cards : Dictionary = {}
	# 卡片ID列表
	if page_card_inst != null :
		for id in self.card_ids :
			var card = page_card_inst.get_card(id)
			if card == null : continue
			to_add_cards[card] = true
		
	# 卡片節點列表
	for each in self.card_nodes :
		if not each.has_method("request_card") : continue
		var card = each.request_card()
		to_add_cards[card] = true
		
	# 設置 卡片ID
	self.page.add_cards(to_add_cards.keys())
	
	# 準備 查詢相關
	self.page.prepare_query()
	
	return self.page

# Private ====================
