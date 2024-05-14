
# Variable ===================

# State ============

## 狀態
var state = null

## 使用主體
var user = null

# Custom ===========

## 目標 PageCard實例 key
var inst_key := ""

## 目標 Page頁面 id (若無指定則為root)
var page := ""

## 目標 組合
var combo := ""

## 目標 查詢
var query := ""

# GDScript ===================

# Extends ====================

# Interface ==================

## 設置 狀態
func set_states (_state) :
	self.states = _state

## 設置 使用主體
func set_user (_user) :
	self.user = _user

## 設置 資料
func set_data (data) :
	
	if data.has("inst") :
		self.inst_key = data["inst"]
	
	if data.has("page") :
		self.page = data["page"]
	
	if data.has("combo") :
		self.combo = data["combo"]
	
	if data.has("query") :
		self.query = data["query"]

## 初始化設置
func setup () :
	pass

## 推進
func process (_dt) :
	pass

## 當 狀態 進入
func on_enter () :
	var page_card_mgr = UREQ.acc(&"Uzil:page_card_mgr")
	
	var pagecard_inst = page_card_mgr.inst(self.inst_key)
	
	var page = pagecard_inst.get_page(self.page)
	if page == null : return
	
	var query_exist := self.query != ""
	
	if self.combo != "" or not query_exist :
		page.combo(self.combo)
	else :
		page.query(self.query)
		
	pagecard_inst.refresh()

## 當 狀態 離開
func on_exit () :
	pass

# Public =====================

# Private ====================

