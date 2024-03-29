extends Node

## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

# Variable ===================

## 辨識
@export var id : String = ""

## 組合:頁面 表 String:Array[String]
@export var combo_to_page_id_list = {}

## 卡片
@export var cards : Array[String] = []

## 頁面
var page = null

# GDScript ===================

func _ready () :
	self.request_page()

func _process (_dt) :
	pass

# Public =====================

func request_page () :
	
	if self.page != null : return self.page
	
	self.page = UREQ.acc("Uzil", "Advance.PageCard").Page.new()
	
	if self.id == "" :
		self.page.id = self.name
	else :
		self.page.id = self.id
	
	for combo in self.combo_to_page_id_list :
		var page_id_list = self.combo_to_page_id_list[combo]
		self.page.add_pages(page_id_list, combo, true)
	
	self.page.cards = self.cards.duplicate()
	
	return self.page

# Private ====================
