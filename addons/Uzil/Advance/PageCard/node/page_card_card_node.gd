extends Node

## PageCard.Card_Node 頁面卡 卡片 節點
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export var id : String = ""

## 標籤
@export var tags : Array[String] = []

## 目標物件 NodePath
@export var targets_nodepath : Array[NodePath] = []

## 卡片
var card = null

# GDScript ===================

func _ready () :
	self.request_card()
	

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
	
	self.card.tags = self.tags.duplicate()
	
	for each in self.targets_nodepath :
		var got_node = self.get_node(each)
		if got_node == null : continue
		
		if self.card.targets.has(got_node) : continue
		self.card.targets.push_back(got_node)
	
	self.card.setup()
	
	return self.card

# Private ====================
