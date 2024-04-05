extends Node

## PageCard.Card_Node 頁面卡 卡片 節點
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

enum CardActiveMode {
	VISIBLE, CALL
}

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = ""

## 標籤
@export var tags : Array[String] = []

## 目標物件
@export var targets : Array[Node] = []

## 註冊 到 實例:[頁面]
@export var reg_to_inst_to_pages : Dictionary = {}

## 卡片
var card = null

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass

# Public =====================

func request_card () :
	
	if self.card != null : return self.card
	
	self.card = UREQ.acc("Uzil", "Advance.PageCard").Card.new()
	
	if self.id == "" :
		self.card.id = self.name
	else :
		self.card.id = self.id
	
	var TagQ = UREQ.acc("Uzil", "TagQ")
	self.card.tags = self.tags.duplicate()
	
	for each in self.targets :
		if each == null : continue
		if self.card.targets.has(each) : continue
		self.card.targets.push_back(each)
	
	var page_card_mgr = UREQ.acc("Uzil", "page_card_mgr")
	for key in self.reg_to_inst_to_pages.keys() :
		
		var inst = page_card_mgr.inst(key)
		inst.reg_card(self.card)
		
		var pages : Array = self.reg_to_inst_to_pages[key]
		for page_key in pages :
			var page = inst.get_page(page_key)
			if page == null : continue
		
	
	return self.card

# Private ====================
