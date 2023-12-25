
## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

# Variable ===================

## 辨識
var id : String = ""

## 當前 組合
var _current_combo := ""

## 組合
var combo_to_pages := {}

## 組合 的 顯示中頁面
var combo_to_show_pages := {}

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
func show_page (page_id = null, combo_key = null) :
	var combo_show_pages := self.get_combo_show_pages(combo_key)
	if page_id != null :
		if combo_show_pages.has(page_id) : return
		combo_show_pages.push_back(page_id)
	else :
		var pages = self.get_combo(combo_key)
		combo_show_pages.clear()
		combo_show_pages.append_array(pages)

## 設置 隱藏
func hide_page (page_id = null, combo_key = null) :
	var combo_show_pages := self.get_combo_show_pages(combo_key)
	if page_id != null :
		if not combo_show_pages.has(page_id) : return
		combo_show_pages.erase(page_id)
	else :
		combo_show_pages.clear()

## 切換 組合
func switch_combo (combo_key : String) :
	self._current_combo = combo_key
	self.get_combo(combo_key)

## 新增 頁面 (別名)
func push_page (page_id : String) :
	self.add_page(page_id, null, true)

## 新增 頁面
func add_page (page_id : String, combo_key = null, is_show := true) :
	var combo_pages : Array = self.get_combo(combo_key)
	
	if combo_pages.has(page_id) : return
	combo_pages.push_back(page_id)
	
	if is_show :
		var combo_show_pages : Array = self.get_combo_show_pages(combo_key)
		if not combo_show_pages.has(page_id) :
			combo_show_pages.push_back(page_id)

## 新增 頁面
func add_pages (page_id_list : Array, combo_key = null, is_show := true) :
	var combo_pages : Array = self.get_combo(combo_key)
	var combo_show_pages : Array = self.get_combo_show_pages(combo_key)
	for page_id in page_id_list :
		
		if not combo_pages.has(page_id) : 
			combo_pages.push_back(page_id)
			
			if is_show :
				if not combo_show_pages.has(page_id) :
					combo_show_pages.push_back(page_id)

## 移除 頁面
func del_page (page_id : String, combo_key = null) :
	var combo_pages : Array = self.get_combo(combo_key)
	if not combo_pages.has(page_id) : return
	combo_pages.erase(page_id)

## 新增 卡片
func add_card (card_id : String) :
	if self.cards.has(card_id) : return
	self.cards.push_back(card_id)
	
## 移除 卡片
func del_card (card_id : String) :
	if not self.cards.has(card_id) : return 
	self.cards.erase(card_id)

## 取得 組合 的 頁面
func get_combo (combo_key = null) -> Array :
	if combo_key == null :
		combo_key = self._current_combo
	
	if self.combo_to_pages.has(combo_key) :
		return self.combo_to_pages[combo_key]
	else :
		var combo := []
		self.combo_to_pages[combo_key] = combo
		return combo

## 取得 組合 的 顯示中頁面
func get_combo_show_pages (combo_key = null) -> Array :
	if combo_key == null :
		combo_key = self._current_combo
	
	if self.combo_to_show_pages.has(combo_key) :
		return self.combo_to_show_pages[combo_key]
	else :
		var combo := []
		self.combo_to_show_pages[combo_key] = combo
		return combo

# Private ====================
