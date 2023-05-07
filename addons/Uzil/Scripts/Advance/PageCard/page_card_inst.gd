extends Node

## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

## 當前頁面
var current_pages : Array[String] = []

## 頁面列表
@export var pages_nodepath : Array[NodePath] = []
var pages := []

## 卡片列表
@export var cards_nodepath : Array[NodePath] = []
var cards := []

## 當 準備完成 事件
var on_ready = null

# GDScript ===================

func _init () :
	# 當準備完成 事件
	self.on_ready = G.v.Uzil.Core.Evt.Inst.new()

func _ready () :
	# 每個指定Node路徑 取得為 Node
	
	for each in self.cards_nodepath :
		var node := self.get_node(each)
		if node : self.cards.push_back(node)
	
	for each in self.pages_nodepath :
		var node := self.get_node(each)
		if node : self.pages.push_back(node)
	
	# 呼叫 當準備完成 事件
	self.on_ready.emit()

func _process (_dt) :
	pass

# Public =====================

## 新增 頁面
func add_page (page) :
	if self.pages.has(page) : return
	self.pages.push_back(page)

## 新增 卡片
func add_card (card) :
	if self.cards.has(card) : return
	self.cards.push_back(card)

# 移除 跟 清除 幾乎很少用到, 有需要再加

## 取得 頁面
func get_pages (page_id : String) :
	var res := []
	for each in self.pages :
		if each.id == page_id :
			res.push_back(each)
	
	if res.size() == 0 :
		return null
	else :
		return res

## 取得 卡片
func get_cards (card_id : String) :
	var res := []
	for each in self.cards :
		if each.id == card_id :
			res.push_back(each)
	
	if res.size() == 0 :
		return null
	else :
		return res

## 前往頁面 (開啟目標 關閉其他)
func go_page (page_id : String) :
	self.go_pages([page_id])

## 前往頁面 (開啟目標 關閉其他)
func go_pages (page_id_list : Array[String]) :
	var to_show_cards : Array[String] = self._get_cards_in_pages(page_id_list)
	
	for card in self.cards :
		if to_show_cards.has(card.id) :
			card.active()
		else :
			card.deactive()
	self.current_pages = page_id_list

## 顯示頁面 (只開啟 不關閉)
func show_page (page_id : String) :
	self.show_pages([page_id])

## 顯示頁面 (只開啟 不關閉)
func show_pages (page_id_list : Array[String]) :
	var to_show_cards : Array[String] = self._get_cards_in_pages(page_id_list)
	for card in self.cards :
		if to_show_cards.has(card.id) :
			card.active()
		

## 隱藏頁面 (只關閉 不開啟)
func hide_page (page_id : String) :
	self.hide_pages([page_id])

## 隱藏頁面 (只關閉 不開啟)
func hide_pages (page_id_list : Array[String]) :
	var to_hide_cards : Array[String] = self._get_cards_in_pages(page_id_list)
	for card in self.cards :
		if to_hide_cards.has(card.id) :
			card.deactive()
		

## 啟用卡片
func active_card (card_id : String) :
	self.active_cards([card_id])

## 啟用卡片
func active_cards (card_id_list : Array[String]) :
	for card in self.cards :
		if card_id_list.has(card.id) :
			card.active()

## 關閉卡片
func deactive_card (card_id : String) :
	self.deactive_cards([card_id])

## 關閉卡片
func deactive_cards (card_id_list : Array[String]) :
	for card in self.cards :
		if card_id_list.has(card.id) :
			card.deactive()
	

# Private ====================

## 取得 所有指定頁面中所有的卡片ID
func _get_cards_in_pages (page_id_list : Array[String]) -> Array[String] :
	# 結果
	var card_id_list : Array[String] = []
	
	# 每個頁面
	for page in self.pages :
		
		# 若 不在 指定頁面中 則 忽略
		if not page_id_list.has(page.id) : continue
		
		# 該頁面的每張卡片
		for card_id in page.cards :
			# 若 不在結果中 則 加入
			if not card_id_list.has(card_id) :
				card_id_list.push_back(card_id)
			
		
	return card_id_list
