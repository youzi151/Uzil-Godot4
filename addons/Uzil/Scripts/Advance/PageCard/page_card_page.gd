
## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

# Variable ===================

## 辨識
var id : String = ""

## 當前 堆疊
var _current_deck := ""

## 堆疊
var deck_to_pages := {}

## 堆疊 的 顯示中頁面
var deck_to_show_pages := {}

## 卡片
var cards : Array[String] = []

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass

# Public =====================

## 取得 ID
func get_id () :
	return self.id

## 設置 顯示
func show_page (page_id = null, deck_key = null) :
	var deck_show_pages := self.get_deck_show_pages(deck_key)
	if page_id != null :
		if deck_show_pages.has(page_id) : return
		deck_show_pages.push_back(page_id)
	else :
		var pages = self.get_deck(deck_key)
		deck_show_pages.clear()
		deck_show_pages.append_array(pages)

## 設置 隱藏
func hide_page (page_id = null, deck_key = null) :
	var deck_show_pages := self.get_deck_show_pages(deck_key)
	if page_id != null :
		if not deck_show_pages.has(page_id) : return
		deck_show_pages.erase(page_id)
	else :
		deck_show_pages.clear()

## 切換 堆
func switch_deck (deck_key : String) :
	self._current_deck = deck_key
	self.get_deck(deck_key)

## 新增 頁面 (別名)
func push_page (page_id : String) :
	self.add_page(page_id, null, true)

## 新增 頁面
func add_page (page_id : String, deck_key = null, is_show := true) :
	var deck_pages : Array = self.get_deck(deck_key)
	
	if deck_pages.has(page_id) : return
	deck_pages.push_back(page_id)
	
	if is_show :
		var deck_show_pages : Array = self.get_deck_show_pages(deck_key)
		if not deck_show_pages.has(page_id) :
			deck_show_pages.push_back(page_id)

## 新增 頁面
func add_pages (page_id_list : Array, deck_key = null, is_show := true) :
	var deck_pages : Array = self.get_deck(deck_key)
	var deck_show_pages : Array = self.get_deck_show_pages(deck_key)
	for page_id in page_id_list :
		
		if not deck_pages.has(page_id) : 
			deck_pages.push_back(page_id)
			
			if is_show :
				if not deck_show_pages.has(page_id) :
					deck_show_pages.push_back(page_id)

## 移除 頁面
func del_page (page_id : String, deck_key = null) :
	var deck_pages : Array = self.get_deck(deck_key)
	if not deck_pages.has(page_id) : return
	deck_pages.erase(page_id)

## 新增 卡片
func add_card (card_id : String) :
	if self.cards.has(card_id) : return
	self.cards.push_back(card_id)
	
## 移除 卡片
func del_card (card_id : String) :
	if not self.cards.has(card_id) : return 
	self.cards.erase(card_id)

## 取得 堆疊 的 頁面
func get_deck (deck_key = null) -> Array :
	if deck_key == null :
		deck_key = self._current_deck
	
	if self.deck_to_pages.has(deck_key) :
		return self.deck_to_pages[deck_key]
	else :
		var deck := []
		self.deck_to_pages[deck_key] = deck
		return deck

## 取得 堆疊 的 顯示中頁面
func get_deck_show_pages (deck_key = null) -> Array :
	if deck_key == null :
		deck_key = self._current_deck
	
	if self.deck_to_show_pages.has(deck_key) :
		return self.deck_to_show_pages[deck_key]
	else :
		var deck := []
		self.deck_to_show_pages[deck_key] = deck
		return deck

# Private ====================
