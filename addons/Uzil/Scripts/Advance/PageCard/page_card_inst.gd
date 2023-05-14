extends Node

## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

## 當前頁面
var current_pages : Array[String] = []

## 根頁面
var root_page = null

## 頁面列表
@export var pages_nodepath : Array[NodePath] = []
var pages := []

## 卡片列表
@export var cards_nodepath : Array[NodePath] = []
var cards := []

## 當 準備完成 事件
var on_ready = null

## 預設 轉場行為
var default_transition_fn = null

# GDScript ===================

func _init () :
	# 當準備完成 事件
	self.on_ready = G.v.Uzil.Core.Evt.Inst.new()

func _ready () :
	
	self.root_page = G.v.Uzil.Advance.PageCard.Page.new()
	self.root_page.id = "_root"
	
	# 每個指定Node路徑 取得為 Node
	for each in self.cards_nodepath :
		var node := self.get_node(each)
		if node : self.reg_card(node)
	
	for each in self.pages_nodepath :
		var node := self.get_node(each)
		if node : self.reg_page(node)
	
	# 呼叫 當準備完成 事件
	self.on_ready.emit()

func _process (_dt) :
	pass

# Public =====================

## 註冊 頁面
func reg_page (page) :
	if self.pages.has(page) : return
	self.pages.push_back(page)

## 註冊 卡片
func reg_card (card) :
	if self.cards.has(card) : return
	self.cards.push_back(card)

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

## 取得 頁面
func get_page (page_id : String) :
	for each in self.pages :
		if each.id == page_id :
			return each
	return null

## 取得 卡片
func get_card (card_id : String) :
	for each in self.cards :
		if each.id == card_id :
			return each

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

## 刷新
func refresh (on_done = null) :
	self.refresh_with_transition(self.default_transition_fn, on_done)

## 刷新
func refresh_with_transition (transition_fn = null, on_done = null) :
	# 總共要顯示的頁面
	var total_show_pages := {}
	# 檢查過的頁面
	var checked_pages := {}
	# 待檢查的頁面
	var to_check_pages := []
	
	# 當前要檢查的頁面
	var curr_page = self.root_page
	
	# 防呆 最大嘗試次數
	var try_time := 100
	
	# 若 還有 頁面 要檢查 (且 未超過最大嘗試次數)
	while curr_page != null and try_time > 0: 
		try_time -= 1
		var show_pages = curr_page.get_deck_show_pages()
		
		# 每一個 有顯示的 子頁面
		for each_page in show_pages :
			
			# 若 未加入 總顯示 則 加入
			if not total_show_pages.has(each_page) : 
				total_show_pages[each_page] = self.get_card
				
				# 若 未加入 檢查過 則 加入
				if not checked_pages.has(each_page) : 
					checked_pages[each_page] = true
					
					var to_check = self.get_page(each_page)
					
					# 加入 待檢查
					to_check_pages.push_back(to_check)
				
		# 從 待檢查 取出 下一個 檢查
		curr_page = to_check_pages.pop_back()
	
	# 所有 要顯示的卡片
	var total_show_cards := {}
	
	# 每個 要顯示的頁面
	for each_show_page in total_show_pages :
		
		each_show_page = self.get_page(each_show_page)
		
		# 的 每張卡片
		for each_card in each_show_page.cards :
			
			# 若 未加入 要顯示的卡片 則 加入
			if not total_show_cards.has(each_card) :
				total_show_cards[each_card] = true
	
	# 要啟用的
	var to_active := []
	# 要關閉的
	var to_deactive := []
	
	# 所有 卡片
	for each_card in self.cards :
		# 若 在 要顯示的卡片中
		if total_show_cards.has(each_card.id) :
			to_active.push_back(each_card)
		else :
			to_deactive.push_back(each_card)
				
	G.v.Uzil.Util.async.waterfall([
		func (ctrlr) :
			# 若 有 轉場行為 則 轉呼叫
			if transition_fn != null : 
				transition_fn.call(to_active, to_deactive, func (is_skip := false) :
					if is_skip :
						ctrlr.skip.call()
					else :
						ctrlr.next.call()
				)
			# 否則 直接 下一階段
			else :
				ctrlr.next.call()
			,
		# 最終 (若不要 可以用ctrlr.skip)
		func (ctrlr) :
			# 啟用 要啟用的
			for each in to_active :
				each.active()
			# 關閉 要關閉的
			for each in to_deactive :
				each.deactive()
			,
	], func () :
		if on_done != null :
			on_done.call()
	)

# Private ====================
