
# Variable ===================

var state = null
var user = null


var inst_key := ""

var page := ""

var deck := ""

# GDScript ===================

# Extends ====================

# Interface ==================

## 設置 狀態
func set_state (_state) :
	self.state = _state

## 設置 使用主體
func set_user (_user) :
	self.user = _user

## 設置 資料
func set_data (data) :
	
	if data.has("inst_key") :
		self.inst_key = data.inst_key
	
	if data.has("page") :
		self.page = data.page
	
	if data.has("deck") :
		self.deck = data.deck

## 初始化
func init (_user) :
	pass

## 推進
func process (_dt) :
	pass

## 當 狀態 進入
func on_enter () :
	var page_card_mgr = UREQ.acc("Uzil", "page_card_mgr")
	
	var page_id = self.page
	if page_id == "" :
		page_id = "_root"
	
	var pagecard_inst = page_card_mgr.inst(self.inst_key)
	var page = pagecard_inst.get_page(page_id)
	if page == null : return
	
	page.switch_deck(self.deck)
	pagecard_inst.refresh()

## 當 狀態 離開
func on_exit () :
	pass

# Public =====================

# Private ====================

