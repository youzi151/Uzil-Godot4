extends Node

## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

## 實體ID
@export var inst_key := "_none"

## 頁面列表
@export var pages_nodepath : Array[NodePath] = []

## 卡片列表
@export var cards_nodepath : Array[NodePath] = []


## 實體
var inst = null

## 當準備好
var on_ready = null

# GDScript ===================

func _init () :
	# 當準備完成 事件
	var Evt = UREQ.access_g("Uzil", "Core.Evt")
	self.on_ready = Evt.Inst.new()

func _ready () :
	
	self.request_inst()

	# 呼叫 當準備完成 事件
	self.on_ready.emit()

func _process (_dt) :
	pass

# Public =====================

func request_inst () :
	
	if self.inst != null : return self.inst
	
	var Inst = UREQ.access_g("Uzil", "Advance.PageCard").Inst
	
	var root_page = null
	var pages := []
	var cards := []
	
	# 每個指定Node路徑 取得為 Node
	for each in self.cards_nodepath :
		var node := self.get_node(each)
		if node : cards.push_back(node.request_card())

	for each in self.pages_nodepath :
		var node := self.get_node(each)
		if node : 
			var page = node.request_page()
			if page.get_id() == "_root" :
				root_page = page
			else :
				pages.push_back(page)
	
	self.inst = Inst.new(root_page)
	if self.inst_key == "_none" :
		self.inst = Inst.new(root_page)
	else :
		self.inst = UREQ.access_g("Uzil", "page_card_mgr").inst(self.inst_key, root_page)
	
	for card in cards :
		self.inst.reg_card(card)
	for page in pages :
		self.inst.reg_page(page)
		
	return self.inst

# Private ====================
