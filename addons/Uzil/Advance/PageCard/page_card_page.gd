
## PageCard.Page 頁面卡 頁面
## 
## 持有 對應的卡片
## 

var PageCard

# Variable ===================

## 辨識
var id : String = ""

## 預設組合
var default_combo : String = ""

## 基底查詢內容
var base_query : String = ""

## 當前查詢內容
var current_query : String = ""

## 被動模式
## 若 開啟 則 自己無法直接控制 卡片開關
var is_passtive_mode : bool = false

## 組合
var _combo_to_query : Dictionary = {}

## 卡片
var _cards : Array = []

## 快取 ID:卡片表
var _id_to_card : Dictionary = {}

## 卡片
var _card_to_state : Dictionary = {}

## 標籤檢索器
var _tag_q = null

## 當 啟用
var on_active = null
## 當 進入
var on_enter = null
## 當 聚焦
var on_focus = null
## 當 失焦
var on_unfocus = null
## 當 離開
var on_exit = null
## 當 關閉
var on_deactive = null

# GDScript ===================

func _init () :
	self.PageCard = UREQ.acc("Uzil", "PageCard")
	
	self._tag_q = UREQ.acc("Uzil", "TagQ").Inst.new()
	
	var Evt_Inst = UREQ.acc("Uzil", "Evt").Inst
	self.on_active = Evt_Inst.new()
	self.on_enter = Evt_Inst.new()
	self.on_focus = Evt_Inst.new()
	self.on_unfocus = Evt_Inst.new()
	self.on_exit = Evt_Inst.new()
	self.on_deactive = Evt_Inst.new()
	
	self.set_default_behaviour(true)

# Public =====================

## 新增 卡片
func add_card (card) :
	if self._cards.has(card) : return
	self._cards.push_back(card)
	self._id_to_card[card.id] = card

## 新增 卡片
func add_cards (cards : Array) :
	for each in cards :
		self.add_card(each)

## 取得 卡片
func get_card (card_id : String) : 
	# 是否需要順便更新
	var is_need_update := false
	
	# 若 快取表中 有 該卡片ID
	if self._id_to_card.has(card_id) :
		var card = self._id_to_card[card_id]
		# 若 實際卡片ID 相符 則 返回
		if card.id == card_id : return card
		# 否則 需要更新
		else : is_need_update = true
	
	# 每張 卡片
	for card in self._cards :
		# 若 ID不同 則 忽略
		if card.id != card_id : continue
		# 若需要更新 則 設置到對照表上
		if is_need_update : 
			self._id_to_card[card_id] = card
		# 返回 該卡片
		return card

## 取得 卡片
func get_cards (is_safe := true) -> Array :
	if is_safe : return self._cards.duplicate()
	else : return self._cards

## 設置 卡片 狀態
func set_card_state (target_card, is_active) :
	var typ = typeof(target_card)
	if typ == TYPE_STRING :
		target_card = self.get_card(target_card)
	
	# 若 卡片不存在 則 返回
	if target_card == null : return
	if not self._cards.has(target_card) : return
	
	self._set_card_state(target_card, is_active)
	

## 取得 卡片 狀態
func get_card_to_state () :
	#G.print("get_card_to_state : %s" % self.id)
	#G.print(self._card_to_state.keys().map(func(key): return "%s : %s" % [key.id, self._card_to_state[key]]))
	return self._card_to_state

# 清空 卡片狀態
func clear_card_to_state () :
	self._card_to_state.clear()

## 設置 組合
func set_combo (combo_id : String, query_str : String) :
	self._combo_to_query[combo_id] = query_str

## 取得 組合
func get_combo (combo_id : String) :
	if not self._combo_to_query.has(combo_id) : return null
	return self._combo_to_query[combo_id]

## 查詢
func combo (combo_id : String, query_mode : int = -1) :
	var query_str = self.get_combo(combo_id)
	if query_str == null : 
		G.print("[page_card_page.gd] combo[%s] not exist." % [combo_id])
		return
	return self.query(query_str, query_mode)

## 查詢
func query (query_str : String, query_mode : int = -1) :
	
	if not self.base_query.is_empty() :
		query_str = "%s %s" % [self.base_query, query_str]
	
	self.current_query = query_str
	
	# 該頁面的卡片ID列表
	var cards : Array = self.get_cards()
	# 標籤查詢結果
	var query_result : Dictionary = self._tag_q.search(query_str)
	
	if query_mode == -1 :
		if self.is_passtive_mode :
			query_mode = PageCard.QueryMode.SHOW_OR_CLEAR
		else :
			query_mode = PageCard.QueryMode.SHOW_OR_HIDE
	
	# 若 需要應用 則
	match query_mode :
		PageCard.QueryMode.INFO :
			# 建立 結果 空字典
			var result = {}
			# 每張卡片 將 狀態 設為 是否在查詢結果中
			for card in cards :
				result[card] = query_result.has(card)
				
			return result
		
		PageCard.QueryMode.SHOW :
			for card in query_result :
				self._set_card_state(card, true)
			return self._card_to_state.duplicate()
		
		PageCard.QueryMode.HIDE :
			for card in query_result :
				self._set_card_state(card, false)
			return self._card_to_state.duplicate()
		
		PageCard.QueryMode.SHOW_OR_CLEAR :
			# 清空 當前狀態
			self._card_to_state.clear()
			# 每張卡片
			for card in cards :
				# 若 不在查詢結果中 則 忽略
				if not query_result.has(card) : continue
				# 否則 設置 顯示
				self._set_card_state(card, true)
			return self._card_to_state.duplicate()
		
		PageCard.QueryMode.HIDE_OR_CLEAR :
			# 清空 當前狀態
			self._card_to_state.clear()
			# 每張卡片
			for card in cards :
				# 若 不在查詢結果中 則 忽略
				if not query_result.has(card) : continue
				# 否則 設置 隱藏
				self._set_card_state(card, false)
			return self._card_to_state.duplicate()
		
		PageCard.QueryMode.SHOW_OR_HIDE :
			# 清空 當前狀態
			self._card_to_state.clear()
			# 每張卡片
			for card in cards :
				self._set_card_state(card, query_result.has(card))
			return self._card_to_state.duplicate()

## 準備 查詢相關
func prepare_query () :
	
	# 清空
	self._tag_q.clear()
	
	# 每張 該頁面中的卡片
	var card_list : Array = self.get_cards()
	for card in card_list :
		var tags = card.tags.duplicate()
		tags.push_back("id:%s" % card.id)
		# 設置 到 標籤檢索器
		self._tag_q.set_tags(card, tags)

## 設置 預設行為
func set_default_behaviour (is_active : bool = true) :
	
	self.on_active.off_by_tag("_default")
	
	if not is_active : return
	
	self.on_active.on(func (ctrlr) :
		if not self.default_combo.is_empty() :
			#G.print("[%s] self.combo(self.default_combo[%s])" % [self.id, self.default_combo])
			self.combo(self.default_combo)
		else :
			self.query("")
	).srt(-1).tag("_default")
	
	self.on_deactive.on(func (ctrlr) :
		self.clear_card_to_state()
		#G.print("[%s] self.clear_card_to_state()" % self.id)
	).srt(-1).tag("_default")

## 當 啟用
func active (data : Dictionary = {}) :
	#G.print("page [%s] active" % self.id)
	await self.on_active.emit(data)

## 當 關閉
func deactive (data : Dictionary = {}) :
	#G.print("page [%s] deactive" % self.id)
	await self.on_deactive.emit(data)

## 當 進入
func enter (data : Dictionary = {}) :
	#G.print("page [%s] enter" % self.id)
	await self.on_enter.emit(data)

## 當 離開
func exit (data : Dictionary = {}) :
	#G.print("page [%s] exit" % self.id)
	await self.on_exit.emit(data)

## 當 聚焦
func focus (data : Dictionary = {}) :
	#G.print("page [%s] focus" % self.id)
	await self.on_focus.emit(data)

## 當 失焦
func unfocus (data : Dictionary = {}) :
	#G.print("page [%s] unfocus" % self.id)
	await self.on_unfocus.emit(data)



# Private ====================

## 設置 卡片啟用狀態
func _set_card_state (card, is_active) :
	
	# 設置 狀態
	if is_active != null :
		self._card_to_state[card] = is_active
	else :
		self._card_to_state.erase(card)
	
	# 若 非被動模式 則 實際 開/關 卡片
	if not self.is_passtive_mode :
		if is_active : 
			card.active()
		else :
			card.deactive()
