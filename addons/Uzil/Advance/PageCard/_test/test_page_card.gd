extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

## 純頁面 節點
@export
var page_only_node : Node = null

## 頁面實體 節點
@export
var pagecard_inst_node : Node = null
## 頁面實體
var pagecard_inst = null

## 查詢輸入框
@export
var query_line_edit : LineEdit = null

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg+"\n")
	, "test_page_card")
	
	# 從 節點 請求 頁面實體
	self.pagecard_inst = self.pagecard_inst_node.request_inst()
	
	# 當 查詢輸入 送出時
	self.query_line_edit.text_submitted.connect(func(_str):
		# 查詢
		self.test_query()
	)
	
	# 設置 頁面樹
	self.pagecard_inst.set_page_tree({
		"page_1" : {
			"page_2" : {},
			"page_3" : null,
		},
		"page_3" : {
			"page_4" : {}
		}
	})
	
	# 所有頁面加上偵錯行為
	var pages = self.pagecard_inst.get_pages()
	for each in pages :
		each.on_active.on(func(ctrlr) : G.print("[%s] : on_active" % each.id))
		each.on_enter.on(func(ctrlr) : G.print("[%s] : on_enter" % each.id))
		each.on_focus.on(func(ctrlr) : G.print("[%s] : on_focus" % each.id))
		each.on_unfocus.on(func(ctrlr) : G.print("[%s] : on_unfocus" % each.id))
		each.on_exit.on(func(ctrlr) : G.print("[%s] : on_exit" % each.id))
		each.on_deactive.on(func(ctrlr) : G.print("[%s] : on_deactive" % each.id))
	
	# 重置 頁面實體
	self.pagecard_inst.restart()
	
	# 在 根頁面上 查詢並啟用 card_0
	self.pagecard_inst.get_root_page().query("card:0 type:main")
	# 刷新
	self.pagecard_inst.refresh()
	

func _exit_tree () :
	G.off_print("test_page_card")

# Extends ====================

# Public =====================

## 測試 純頁面
func test_page_only () :
	var invoker = UREQ.acc(&"Uzil:invoker_mgr").inst()
	
	var page = self.page_only_node.request_page()
	
	G.print('page_only : query to ""')
	page.query("")
	
	await invoker.wait(1000)
	G.print('page_only : combo to "combo_1"')
	page.combo("combo_1")
	
	await invoker.wait(1000)
	G.print('page_only : combo to "combo_2"')
	page.combo("combo_2")
	
	await invoker.wait(1000)
	G.print('page_only : query to "+card:1,3"')
	page.query("+card:1,3")
	
	await invoker.wait(1000)
	G.print('page_only : query to "+2,1"')
	page.query("+2,1")
	
	await invoker.wait(1000)
	G.print('page_only : query to "id:card_2 +card_3"')
	page.query("id:card_2 +card_3")
	

## 查詢
func test_query () :
	var query_str := self.query_line_edit.text
	var res = self.pagecard_inst.get_root_page().query(query_str)
	#G.print(res.keys().map(func(key): return "%s:%s" % [key.id, res[key]]))
	self.pagecard_inst.refresh()

## 測試 頁面實體 倒回
func test_page_inst_back () :
	self.pagecard_inst.back()
	self.pagecard_inst.refresh()

## 測試 頁面實體 切換
func test_page_inst_change () :
	var page = self.pagecard_inst.get_page()
	match page.id :
		"page_1", "page_2" :
			await self.pagecard_inst.change("page_3")
		"page_3", "page_4" :
			await self.pagecard_inst.change("page_1")
	self.pagecard_inst.refresh()

## 測試 頁面實體 開啟 (向左)
func test_page_inst_open_left () :
	var page = self.pagecard_inst.get_page()
	match page.id :
		"_root" :
			await self.pagecard_inst.open("page_1")
		"page_1" :
			await self.pagecard_inst.open("page_2")
		"page_3" :
			await self.pagecard_inst.open("page_2")
		"page_4" :
			await self.pagecard_inst.open("page_2")
		_ :
			return
	
	self.pagecard_inst.get_page().combo("highlight")
	self.pagecard_inst.refresh()

## 測試 頁面實體 開啟 (向右)
func test_page_inst_open_right () :
	var page = self.pagecard_inst.get_page()
	match page.id :
		"_root" :
			await self.pagecard_inst.open("page_3")
		"page_1" :
			await self.pagecard_inst.open("page_3")
		"page_2" :
			await self.pagecard_inst.open("page_4")
		"page_3" :
			await self.pagecard_inst.open("page_4")
		_ :
			return
	
	self.pagecard_inst.get_page().combo("highlight")
	self.pagecard_inst.refresh()

## 測試 頁面實體 導航 (至左上)
func test_page_inst_nav_top_left () :
	self.pagecard_inst.nav("page_2")
	self.pagecard_inst.refresh()

## 測試 頁面實體 導航 (至左上, 且 需經過page_1)
func test_page_inst_nav_top_right_through_1 () :
	self.pagecard_inst.nav("page_4", {"through":["page_1"]})
	self.pagecard_inst.refresh()

## 測試 頁面實體 導航 (至左上, 且 需避開page_1)
func test_page_inst_nav_top_right_without_1 () :
	self.pagecard_inst.nav("page_4",  {"without":["page_1"]})
	self.pagecard_inst.refresh()

## 測試 頁面實體 導航 (至左上, 且 跳接從page_3開始)
func test_page_inst_nav_top_right_graft_on_3 () :
	self.pagecard_inst.nav("page_4",  {"graft":"page_3"})
	self.pagecard_inst.refresh()

## 測試 頁面實體 導航 相關
func test_page_inst_nav () :
	var invoker = UREQ.acc(&"Uzil:invoker")
	
	self.pagecard_inst.restart()
	
	var page_1 = self.pagecard_inst.get_page("page_1")
	var page_2 = self.pagecard_inst.get_page("page_2")
	var page_3 = self.pagecard_inst.get_page("page_3")
	var page_4 = self.pagecard_inst.get_page("page_4")
	
	# 進入 page_4 並 經過 page_1
	self.pagecard_inst.nav("page_4", {"through":["page_1"]})
	page_1.combo("combo_highlight")
	page_3.combo("combo_highlight")
	page_4.combo("combo_highlight")
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 回到 根頁面
	self.pagecard_inst.nav("_root")
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 重新進入 page_4 並 經過 page_1
	# page_1,3,4 應已重設為combo:default 而非highlight狀態
	self.pagecard_inst.nav("page_4", {"through":["page_1"]})
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 顯示highlight狀態
	page_1.combo("combo_highlight")
	page_3.combo("combo_highlight")
	page_4.combo("combo_highlight")
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 回到 根頁面
	self.pagecard_inst.nav("_root")
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 進入 page_4 並 避開 page_1
	self.pagecard_inst.nav("page_4", {"without":["page_1"]})
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 重新前往 page_4(當前頁面) 並 要求路徑經過page_1 (並非要求堆疊含有page_1即可)
	# 應 會回到 page_1為基底後 重新進入
	self.pagecard_inst.nav("page_4", {"through":["page_1"]})
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	
	# 重新前往 page_4(當前頁面) 沒有特別要求
	# 應 為 無效
	self.pagecard_inst.nav("page_4")
	self.pagecard_inst.refresh()
	await invoker.wait(1000)
	
	# 重新前往 page_4(當前頁面) 需 經過根頁面 且 避開page_1
	self.pagecard_inst.nav("page_4", {"through":["_root"], "without":["page_1"]})
	self.pagecard_inst.refresh()
	await invoker.wait(1000)

# Private ====================
