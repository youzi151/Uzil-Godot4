
## PageCard.Inst 頁面卡 實體
## 
## 持有 多個頁面 與 多個卡片. 提供外部操作, 來進行頁面的切換/顯示/隱藏.
## 

# Variable ===================

## 根頁面
var _root_page = null

## 頁面列表
var _pages : Array = []
## 快取 ID:頁面表
var _id_to_page : Dictionary = {}

## 卡片列表
var _cards : Array = []
## 快取 ID:卡片表
var _id_to_card : Dictionary = {}

## 卡片:(多重數值)啟用狀態
var _card_to_active_vals : Dictionary = {}

## 當前頁面
var _current_page = null

## 頁面堆疊
var _page_stack : Array = []

## 頁面樹
var _page_graph = null
## 頁面樹 路徑點ID:頁面
var _graph_id_to_page := {}
## 頁面樹 頁面:路徑點ID
var _page_to_graph_id := {}
## 頁面:接續頁面
var _page_to_next_pages := {}

## 預設 轉場行為
var default_transition_fn = null

# GDScript ===================

func _init () :
	var PageCard = UREQ.acc(&"Uzil:Advance.PageCard")
	
	var Graph = UREQ.acc(&"Uzil:Util").Graph
	self._page_graph = Graph.new()
	
	# 根頁面
	self._root_page = PageCard.Page.new()
	self._root_page.id = "_root"
	
	self.reg_page(self._root_page)
	
	self._current_page = self._root_page
	self._page_stack.push_back(self._root_page)

# Public =====================

## 註冊 頁面
func reg_page (page) :
	if self._pages.has(page) : return
	# 加入 頁面列表
	self._pages.push_back(page)
	# 若 有指定ID 則 加入快取
	if not page.id.is_empty() :
		self._id_to_page[page.id] = page
		
	# 開啟 被動模式
	page.is_passtive_mode = true

## 註冊 卡片
func reg_card (card) :
	if self._cards.has(card) : return
	# 加入 卡片列表
	self._cards.push_back(card)
	# 若 有指定ID 則 加入快取
	if not card.id.is_empty() :
		self._id_to_card[card.id] = card
	
	# 添加 啟用狀態(多重數值)
	var is_active_vals = UREQ.acc(&"Uzil:Core.Vals").new().set_default(false)
	self._card_to_active_vals[card] = is_active_vals
	
	self._root_page.add_card(card)
	self._root_page.prepare_query()

## 取得 根頁面
func get_root_page () :
	return self._root_page

## 取得 頁面
func get_page (page_id: String = "") :
	if page_id == "" : return self._current_page
	if page_id == "_root" : return self._root_page
	
	# 是否需要順便更新
	var is_need_update := false
	
	# 若 快取表中 有 該頁面ID
	if self._id_to_page.has(page_id) :
		var page = self._id_to_page[page_id]
		# 若 實際頁面ID 相符 則 返回
		if page.id == page_id : return page
		# 否則 需要更新
		else : is_need_update = true
	
	# 每張 頁面
	for page in self._pages :
		# 若 ID不同 則 忽略
		if page.id != page_id : continue
		# 若需要更新 則 設置到對照表上
		if is_need_update : 
			self._id_to_page[page_id] = page
		# 返回 該頁面
		return page
	
	return null

## 取得 頁面
func get_pages () :
	return self._pages.duplicate()

## 取得 卡片
func get_card (card_id: String) :
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
	
	return null

## 取得 卡片
func get_cards () :
	return self._cards.duplicate()


## 重新開始
func restart () :
	var stack_size := self._page_stack.size()
	
	var to_exit := []
	
	# 當前頁面
	if self._current_page != self._root_page :
		self._current_page.unfocus()
	
	# 每個 堆疊中的頁面 (除了 根頁面)
	for idx in range(stack_size-1, 0, -1) :
		var page = self._page_stack[idx]
		if page == null : continue
		to_exit.push_back(page)
	# 先離開
	for page in to_exit :
		await page.exit()
	# 再關閉
	for page in to_exit :
		await page.deactive()
	
	# 清空
	self._current_page = self._root_page
	self._page_stack.clear()
	self._page_stack.push_back(self._root_page)
	
	# 清空 啟用狀態 多重數值
	for card in self._card_to_active_vals :
		var vals = self._card_to_active_vals[card]
		vals.clear()
	
	# 刷新
	self.calculate_page_tree()
	self.refresh()

## 頁面 開啟
func open (page_id: String, data := {}) :
	var next_page = self.get_page(page_id)
	if next_page == null : return false
	if next_page == self._current_page : return false
	
	# 更換 當前頁面
	var last_page = self._current_page
	var last_page_exist := last_page != null
	
	# 是否在頁面堆中
	var is_in_stack := self._page_stack.has(next_page)
	
	# 加入 堆疊
	self._page_stack.push_back(next_page)
	# 若 下個頁面 未在頁面堆中 啟用 下個頁面
	if not is_in_stack :
		await next_page.active(data)
	# 進入 下個頁面
	await next_page.enter(data)
	# 轉移焦點
	await last_page.unfocus(data)
	self._current_page = next_page
	await next_page.focus(data)
	
	# 若 不在頁面堆疊中 則 關閉 前個頁面
	if not self._page_stack.has(last_page) :
		await last_page.deactive()
	
	return true
	

## 頁面 返回
func back (until_page_id: String = "", data := {}) :
	#G.print("self._page_stack")
	#G.print(self._page_stack.map(func(a):return a.id))
	
	# 若 除了根頁面以外 無堆疊頁面 則 返回
	if self._page_stack.size() == 1 : return
	
	# 要返回到的頁面
	var back_to_page = null
	
	# 要離開的頁面
	var to_exit_pages := []
	# 要關閉的頁面
	var to_deactive_pages := []
	
	# 每個 頁面堆疊 (直到根頁面)
	for idx in range(self._page_stack.size()-1, 0, -1) : 
		
		var each_page = self._page_stack.pop_back()
		
		# 加入至 要離開的頁面
		to_exit_pages.push_back(each_page)
		# 若 在頁面堆疊中已經沒有該頁 則 加入 要關閉的頁面
		if not self._page_stack.has(each_page) :
			to_deactive_pages.push_back(each_page)
		
		var next_page = self._page_stack[idx-1]
		# 若 有 指定 直到頁面 且 該頁面 未達 指定直到頁面
		if until_page_id != "" and next_page.id != until_page_id :
			continue
		
		# 取得 要返回到的頁面 為 下個頁面
		back_to_page = next_page
		break
		
	if back_to_page == null : return
	
	# 轉移 焦點
	await self._current_page.unfocus(data)
	self._current_page = back_to_page
	await self._current_page.focus(data)
	
	# 每個 要離開的頁面 離開
	for each in to_exit_pages :
		await each.exit(data)
	# 每個 要關閉的頁面 關閉
	for each in to_deactive_pages :
		await each.deactive(data)

## 頁面 變更
func change (page_id: String, data := {}) :
	var next_page = self.get_page(page_id)
	if next_page == null : return
	if next_page == self._current_page : return
	
	var last_page = self._current_page
	
	# 是否在頁面堆中
	var is_in_stack := self._page_stack.has(next_page)
	
	# 交換堆疊最上層頁面
	self._page_stack.pop_back()
	self._page_stack.push_back(next_page)
	
	# 啟用 目標頁面
	if not is_in_stack :
		await next_page.active(data)
	# 進入 目標頁面
	await next_page.enter(data)
	
	# 轉移 焦點
	await self._current_page.unfocus(data)
	self._current_page = next_page
	await self._current_page.focus(data)
	# 離開 前個頁面
	await last_page.exit(data)
	# 若 不在頁面堆疊中 則 關閉 前個頁面
	if not self._page_stack.has(last_page) :
		await last_page.deactive(data)

func nav (page_id, options := {}) :
	#G.print("self._page_stack")
	#G.print(self._page_stack.map(func(a):return a.id))
	
	# 自訂資料
	var data : Dictionary = {}
	if options.has("data") :
		data = options["data"]
	
	# 計算 導航相關資料
	var nav_data = self._get_nav_data(page_id, options)
	
	#G.print("nav_data : ")
	#G.print(nav_data)
	
	# 若 導航資料 不存在 或 未成功 則 返回
	if nav_data == null : return
	if not nav_data["is_success"] : return
	
	#G.print("backward_path : ")
	#G.print(nav_data["backward_path"])
	
	#G.print("forward_path : ")
	#G.print(nav_data["forward_path"])
	
	#G.print("searched_paths : ")
	#G.print(nav_data["searched_paths"])
	
	# 前個頁面
	var last_page = self._current_page
	# 目標頁面
	var next_page = self.get_page(page_id)
	
	# 倒回/前進 路線
	var backward_path : Array = nav_data["backward_path"]
	var forward_path : Array = nav_data["forward_path"]
	var backward_path_size : int = backward_path.size()
	var forward_path_size : int = forward_path.size()
	
	# 若 沒有倒回 沒有前進 前個頁面與目標頁面一樣 則 不動作
	if backward_path_size == 0 and forward_path_size == 0 and last_page == next_page :
		return
	
	# 倒回路徑上 的 頁面 (不包含基底或目標)
	var backward_pages : Array = []
	for idx in range(backward_path_size) :
		var each = backward_path[idx]
		var page = self._graph_id_to_page[each]
		backward_pages.push_back(page)
	
	# 前進路徑上 的 頁面 (不包含目標)
	var forward_pages : Array = []
	for idx in range(forward_path_size) :
		var each = forward_path[idx]
		var page = self._graph_id_to_page[each]
		forward_pages.push_back(page)
	
	# 啟動 所有 未在堆疊中的 前進頁面
	for each in forward_pages :
		if not self._page_stack.has(each) :
			await each.active(data)
	# 啟動 未在堆疊中的 目標頁面
	if not self._page_stack.has(next_page) :
		await next_page.active(data)
	
	# 進入 所有 前進頁面
	for each in forward_pages :
		await each.enter(data)
	# 進入 目標頁面
	await next_page.enter(data)
	
	# 轉移焦點
	await self._current_page.unfocus(data)
	self._current_page = next_page
	await self._current_page.focus(data)
	
	# 堆疊 移除 每個 倒退頁面(含 當前頁面)
	for each in backward_pages :
		self._page_stack.pop_back()
	# 堆疊 加入 每個 前進頁面
	for each in forward_pages :
		self._page_stack.push_back(each)
	# 堆疊 加入 目標頁面
	self._page_stack.push_back(next_page)
	
	# 離開 所有 倒退頁面(含 當前頁面)
	for each in backward_pages :
		await each.exit(data)
	
	# 關閉 所有 倒退頁面(含 當前頁面)
	for each in backward_pages :
		if not self._page_stack.has(each) :
			await each.deactive(data)
	
	#G.print(self._current_page.id)

	#G.print("self._page_stack")
	#G.print(self._page_stack.map(func(a):return a.id))

## 刷新畫面
func refresh (transition_fn = null, transition_data := {}) :
	
	# 要啟用的
	var to_active := []
	# 要關閉的
	var to_deactive := []
	
	# 轉場方法
	if transition_fn == null :
		transition_fn = self.default_transition_fn
	
	# 清空 所有 卡片與啟用狀態多重數值
	for each in self._card_to_active_vals :
		self._card_to_active_vals[each].clear()
	
	# 設置 所有 卡片與啟用狀態多重數值 為 預設啟用
	for card in self._cards :
		self._card_to_active_vals[card].set_default(false)
	
	# 每個頁面
	for page in self._pages :
		# 取得 頁面的卡片與啟用狀態
		var card_to_state : Dictionary = page.get_card_to_state()
		#G.print("page[%s] %s" % [page.id, card_to_state.keys().map(func(a): return "%s : %s" % [a.id, card_to_state[a]])])
		# 每個 卡片:啟用狀態 設置到 多重數值
		for card in card_to_state :
			if not self._cards.has(card) :
				G.error("[PageCard.Inst] inst not include card %s" % [card])
				continue
			self._card_to_active_vals[card].set_data(page, card_to_state[card])
	
	# 所有 卡片與啟用狀態多重數值
	for card in self._card_to_active_vals :
		var vals = self._card_to_active_vals[card]
		var is_active = vals.current()
		var user = vals.current_user()
		
		# 依照數值 排到 待啟用 或 待關閉
		if is_active : to_active.push_back(card)
		else : to_deactive.push_back(card)
	
	#G.print("to_active : %s" % [to_active.map(func(a):return a.id)])
	#G.print("to_deactive : %s" % [to_deactive.map(func(a):return a.id)])
	
	var Util = UREQ.acc(&"Uzil:Util")
	await Util.async.waterfall([
		func(ctrlr) :
			# 若 有 轉場行為 則 轉呼叫
			if transition_fn != null : 
				
				transition_data["to_active"] = to_active
				transition_data["to_deactive"] = to_deactive
				
				var ref := {
					is_callback_called = false
				}
				
				var is_skip = await transition_fn.call(transition_data)
				
				if ref.is_callback_called : return
				match is_skip :
					true : 
						ctrlr.skip()
					_ : 
						ctrlr.next()
				
			# 否則 直接 下一階段
			else :
				ctrlr.next()
			,
		# 最終 (若不要, 可以在transition_fn的回傳is_skip=true)
		func(ctrlr) :
			# 啟用 要啟用的
			await Util.async.each(to_active, func(idx, each, each_ctrlr) :
				await each.active()
				each_ctrlr.next()
			)
			
			# 關閉 要關閉的
			await Util.async.each(to_deactive, func(idx, each, each_ctrlr) :
				await each.deactive()
				each_ctrlr.next()
			)
			
			ctrlr.next()
	])

## 設置 頁面樹
func set_page_tree (tree_dict: Dictionary) :
	var queue := [[self._root_page.id, tree_dict]]
	
	#G.print("set_page_tree========")
	while queue.size() > 0 :
		var pair : Array = queue.pop_back()
		var page = pair[0]
		var next_to_sub_nexts = pair[1]
		
		if next_to_sub_nexts == null : continue
		
		#G.print("%s == %s" % [page, next_to_sub_nexts.keys()])
		self.set_page_next(page, next_to_sub_nexts.keys())
		for next in next_to_sub_nexts :
			var sub_pair : Array = [next, next_to_sub_nexts[next]]
			queue.push_back(sub_pair)
	
	#G.print("=====================")
	self.calculate_page_tree()

## 設置 頁面樹中 頁面的後續頁面
func set_page_next (page_or_id, next_pages: Array) :
	var page = self._get_target_page(page_or_id)
	if page == null : return
	
	# 取得 頁面的後續頁面
	var nexts : Array = self._get_page_nexts(page)
	# 清空當前
	nexts.clear()
	# 設置 頁面的後續頁面
	for each_target in next_pages :
		var each_page = self._get_target_page(each_target)
		if each_page == null : continue
		nexts.push_back(each_page)

## 刷新 頁面樹
func calculate_page_tree () :
	# 清空 頁面樹圖
	self._page_graph.clear()
	
	# 重新設置 頁面與路徑點ID
	var increase_id := 0
	for page in self._pages :
		self._page_to_graph_id[page] = increase_id
		self._graph_id_to_page[increase_id] = page
		increase_id += 1
	
	# 每個 頁面路徑點
	for page in self._page_to_graph_id :
		var graph_id : int = self._page_to_graph_id[page]
		# 取得 後續頁面
		var nexts := {}
		var page_nexts = self._get_page_nexts(page)
		#G.print("%s : %s" % [graph_id, page_nexts.map(func(each): return each.id)])
		if page_nexts != null :
			for next in page_nexts :
				var next_id : int = self._page_to_graph_id[next]
				nexts[next_id] = 1
		# 設置到 路徑點的後續路徑
		self._page_graph.set_point(graph_id, {
			"nexts" : nexts,
		})
	
	self._page_graph.refresh()
	


# Private ====================

## 取得目標頁面
func _get_target_page (page_or_id) :
	var typ = typeof(page_or_id)
	match typ :
		TYPE_STRING :
			return self.get_page(page_or_id)
		TYPE_OBJECT :
			return page_or_id
		_ :
			return null

## 取得 頁面的後續頁面
func _get_page_nexts (page_id) :
	var page = self._get_target_page(page_id)
	if page == null : return null
	
	if not self._page_to_next_pages.has(page) : 
		var nexts := []
		self._page_to_next_pages[page] = nexts
		return nexts
	else :
		return self._page_to_next_pages[page]

## 取得 當前頁面 至 目標頁面 的 導航資料
func _get_nav_data (page_id, options) :
	# 目標頁面
	var target_page = self.get_page(page_id)
	if target_page == null : return
	if not self._page_to_graph_id.has(target_page) : return
	
	# 結果
	var nav_result := {
		"is_success" : false,
		"backward_path" : null,
		"forward_path" : null,
		"searched_paths" : null,
	}
	var forward_path : Array = []
	var backward_path : Array = []
	
	# 搜尋選項
	var find_opts := {
		# 方向 反轉 (朝src而非next搜尋)
		"direction" : -1,
	}
	
	# 接枝到
	var is_graft := false
	var graft_id : int = -1
	if options.has("graft") :
		var graft_page_id : String = options["graft"]
		var graft_page = self.get_page(graft_page_id)
		if self._page_to_graph_id.has(graft_page) :
			graft_id = self._page_to_graph_id[graft_page]
			is_graft = true
		
	
	# 需要有序經過的頁面
	var through_pages : Array = []
	if options.has("through") :
		through_pages = options["through"]
	# 需要有序經過的頁面 路徑ID
	var through_graph_ids : Array[int] = []
	var through_in_stack : Array[int] = []
	for each in through_pages :
		var through_page = self.get_page(each)
		if through_page == null : return
		if not self._page_to_graph_id.has(through_page) : return
		var through_graph_id : int = self._page_to_graph_id[through_page]
		through_graph_ids.push_back(through_graph_id)
	
	# 需要無序經過的頁面
	var require_pages : Array = []
	if options.has("require") :
		require_pages = options["require"]
	# 需要無序經過的頁面 路徑ID
	var require_graph_ids_dict : Dictionary = {}
	for each in require_pages :
		var require_page = self.get_page(each)
		if require_page == null : return
		if not self._page_to_graph_id.has(require_page) : return
		var require_graph_id : int = self._page_to_graph_id[require_page]
		require_graph_ids_dict[require_graph_id] = true
	
	# 需要避開的頁面
	var without_pages : Array = []
	if options.has("without") :
		without_pages = options["without"]
	# 需要避開的頁面 路徑ID
	var without_graph_ids : Array[int] = []
	for each in without_pages :
		var without_page = self.get_page(each)
		if without_page == null : return
		if not self._page_to_graph_id.has(without_page) : return
		var without_graph_id : int = self._page_to_graph_id[without_page]
		without_graph_ids.push_back(without_graph_id)
	
	#== 處理堆疊相關 ========
	
	# 先反轉 需要有序經過的路徑點, 方便操作
	through_graph_ids.reverse()
	# 需要有序經過的路徑點 的 首端(起點 _root)
	var through_graph_ids_head = null
	if through_graph_ids.size() > 0 :
		through_graph_ids.back()
	
	# 頁面堆疊 路徑點ID
	var stack_graph_ids : Array[int] = []
	for idx in range(self._page_stack.size()) :
		var page = self._page_stack[idx]
		var graph_id = self._page_to_graph_id[page]
		
		stack_graph_ids.push_back(graph_id)
		
		# 若 需要有序經過的路徑點 的 首端 為 該路徑點 則
		if graph_id == through_graph_ids_head :
			through_in_stack.push_back(graph_id)
			# 從 列表中 移除
			through_graph_ids.pop_back()
			# 推進首端
			if through_graph_ids.size() > 0 :
				through_graph_ids_head = through_graph_ids.back()
			else :
				through_graph_ids_head = null
		
		# 若 需要無序經過的路徑點 有 該路徑點 則 從 列表中 移除
		if require_graph_ids_dict.has(graph_id) :
			require_graph_ids_dict.erase(graph_id)
	
	# 反轉回復 需要有序經過的路徑點
	through_graph_ids.reverse()
	
	#== 處理堆疊相關完畢 =====
	
	# 目標 與 當前 路徑點ID
	var target_graph_id : int = self._page_to_graph_id[target_page]
	var current_graph_id : int = self._page_to_graph_id[self._current_page]
	
	#G.print("current and stack_graph_ids")
	#G.print(stack_graph_ids)
	
	# 若 需要有序經過路徑點 存在 則 設置到選項
	if through_graph_ids.size() > 0 :
		find_opts["through"] = through_graph_ids
	# 若 需要無序經過路徑點 存在 則 設置到選項
	if require_graph_ids_dict.size() > 0 :
		find_opts["require"] = PackedInt32Array(require_graph_ids_dict.keys())
	# 若 需要避開路徑點 存在 則 設置到選項
	if without_graph_ids.size() > 0 :
		find_opts["without"] = without_graph_ids
	
	# 倒回路徑
	var back_path : Array[int] = []
	# 搜尋反轉路徑列表
	var found_reverse_paths : Array = []
	# 搜尋結果
	var found_result : Dictionary = {}
	
	var is_check_without : bool = without_graph_ids.size() > 0
	
	# 是否搜尋 頁面堆疊
	var is_search_page_stack := true
	
	# 每個 頁面堆疊 的 路徑點ID (除了基底)
	var to_search_stack_reverse : Array = []
	
	# 若有 指定接枝 則 取代要搜尋的堆疊
	if is_graft :
		to_search_stack_reverse = [graft_id]
		is_search_page_stack = false
	# 否則 設置為 反轉的頁面堆疊
	else :
		to_search_stack_reverse = stack_graph_ids.duplicate()
		to_search_stack_reverse.reverse()
	
	var stack_size : int = to_search_stack_reverse.size()
	for idx_r in range(stack_size) :
		var caret_graph_id : int = to_search_stack_reverse[idx_r]
		
		var is_need_find_path : bool = true
		
		# 若 該路徑點以下的堆疊中路徑點 與 要避免的路徑點 有重疊 則 忽略尋找
		if is_check_without : 
			for each in without_graph_ids :
				for idx in range(stack_size - idx_r) :
					if stack_graph_ids[idx] == each :
						is_need_find_path = false
						break
				if not is_need_find_path :
					break
			
		
		# 若 有要尋找
		if is_need_find_path :
			
			# 搜尋 從 目標 爬回 當前路徑點 的 路徑
			found_result = self._page_graph.find_path(target_graph_id, caret_graph_id, find_opts)
			
			# 若 搜尋路徑 存在
			if found_result.result_paths.size() > 0 :
				found_reverse_paths = found_result.result_paths
				break
			
			# 若 搜尋資料 存在 則 設置到選項中 沿用
			if found_result.has("searched_paths") :
				find_opts["searched_paths"] = found_result["searched_paths"]
				
		
		if is_search_page_stack :
			# 加入 倒回路徑
			back_path.push_back(caret_graph_id)
		
	
	# 設置 倒回路徑 到 結果
	backward_path = back_path
	#G.print("backward_path")
	#G.print(backward_path)
	
	# 若 有搜尋到
	var found_count := found_reverse_paths.size()
	if found_count > 0 :
		# 若有 多筆結果 則 以短到長排序
		if found_count >= 2 :
			found_reverse_paths.sort_custom(func(a, b): return a.size() < b.size())
		
		# 取得 路徑
		forward_path = found_reverse_paths[0]
		# 剔除 起點
		forward_path.pop_back()
		
		# 若 有 指定接枝 則 加入
		if is_graft :
			forward_path.push_back(graft_id)
		
		# 反轉
		forward_path.reverse()
		
	# 設置 成功
	var is_success : bool = backward_path.size() != 0 or forward_path.size() != 0
	is_success = is_success or target_graph_id != current_graph_id
	nav_result["backward_path"] = backward_path
	nav_result["forward_path"] = forward_path
	nav_result["is_success"] = is_success
	
	# 設置 搜尋資料 到 結果
	if found_result.has("searched_paths") :
		nav_result["searched_paths"] = found_result["searched_paths"]
	
	return nav_result
