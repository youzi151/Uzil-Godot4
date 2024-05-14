@tool
extends Node

## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

## 是否註冊
@export var is_reg_to_mgr := true :
	set (value) :
		is_reg_to_mgr = value
		if Engine.is_editor_hint() :
			self.notify_property_list_changed()

## 實體ID
@export var inst_key := ""

## 頁面列表
@export var page_nodes : Array[Node] = []

## 卡片列表
@export var card_nodes : Array[Node] = []



## 實體
var inst = null

## 當準備好
var on_ready = null

# GDScript ===================

func _init () :
	if Engine.is_editor_hint() : return
	# 當準備完成 事件
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	self.on_ready = Evt.Inst.new()

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_inst()

func _validate_property (property: Dictionary) :
	match property.name : 
		"inst_key" :
			if self.is_reg_to_mgr :
				property.usage |= PROPERTY_USAGE_EDITOR
			else :
				property.usage ^= PROPERTY_USAGE_EDITOR

# Public =====================

func request_inst () :
	
	if self.inst != null : return self.inst
	
	var Inst = UREQ.acc(&"Uzil:Advance.PageCard").Inst
	
	var root_page = null
	var pages := {}
	var cards := {}
	
	# 每個 卡片 節點
	for node in self.card_nodes :
		if node == null : continue
		# 請求/建立 卡片
		var card = node.request_card()
		# 加入 卡片
		if not cards.has(card) :
			cards[card] = true
	
	# 每個 頁面 節點
	for node in self.page_nodes :
		if node == null : continue
		
		# 請求/建立 頁面
		var page = node.request_page()
		var cards_of_page : Array = page.get_cards(false)
		# 加入 頁面 的 卡片
		for card in cards_of_page :
			if not cards.has(card) :
				cards[card] = true
		# 加入 頁面
		if not pages.has(page) :
			pages[page] = true
	
	if self.is_reg_to_mgr :
		self.inst = UREQ.acc(&"Uzil:page_card_mgr").inst(self.inst_key)
	else :
		self.inst = Inst.new()
	
	for card in cards.keys() :
		self.inst.reg_card(card)
	for page in pages.keys() :
		self.inst.reg_page(page)
		
	return self.inst

# Private ====================
