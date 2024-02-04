extends Node

## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

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
	# 當準備完成 事件
	var Evt = UREQ.acc("Uzil", "Core.Evt")
	self.on_ready = Evt.Inst.new()

func _ready () :
	self.request_inst()

func _process (_dt) :
	pass

# Public =====================

func request_inst () :
	
	if self.inst != null : return self.inst
	
	var Inst = UREQ.acc("Uzil", "Advance.PageCard").Inst
	
	var root_page = null
	var pages := []
	var cards := []
	
	# 每個 卡片 節點
	for node in self.card_nodes :
		if node == null : continue
		# 請求/建立 卡片
		var card = node.request_card()
		# 加入 卡片
		cards.push_back(card)
	
	# 每個 頁面 節點
	for node in self.page_nodes :
		if node == null : continue
		
		# 請求/建立 頁面
		var page = node.request_page()
		
		# 加入 頁面
		if page.id == "_root" :
			root_page = page
		else :
			pages.push_back(page)
	
	self.inst = Inst.new(root_page)
	if self.inst_key == "" :
		self.inst = Inst.new(root_page)
	else :
		self.inst = UREQ.acc("Uzil", "page_card_mgr").inst(self.inst_key, root_page)
	
	for card in cards :
		self.inst.reg_card(card)
	for page in pages :
		self.inst.reg_page(page)
		
	return self.inst

# Private ====================
