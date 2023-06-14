# desc ==========

## 索引 PageCard 頁面卡
##
## 透過指定頁面來開關對應的卡片(物件).[br]
## 也可在編輯器中操作設置所有頁面與卡片.
## 

# const =========

## 路徑
var PATH : String

## Uzil
var Uzil

# sub_index =====

## 管理器
var Mgr
## 實體
var Inst
## 頁面
var Page
## 卡片
var Card

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.Uzil = Uzil
	self.PATH = _parent_index.PATH.path_join("PageCard")
	
	# 綁定 索引
	UREQ.bind_g("Uzil", "Advance.PageCard", self._target_index, {
		"alias" : ["PageCard"]
	})
	
	# 綁定 實體管理
	UREQ.bind_g("Uzil", "page_card_mgr", self._target_pagecard, {
		"alias" : ["page_card", "pagecard"],
		"requires" : ["Advance.PageCard"],
	})
	
	return self

## 產生 綁定對象 索引
func _target_index () :
	self.Mgr = self.Uzil.load_script(self.PATH.path_join("page_card_mgr.gd"))
	self.Inst = self.Uzil.load_script(self.PATH.path_join("page_card_inst.gd"))
	self.Page = self.Uzil.load_script(self.PATH.path_join("page_card_page.gd"))
	self.Card = self.Uzil.load_script(self.PATH.path_join("page_card_card.gd"))
	
	return self

## 產生 綁定對象 實體管理
func _target_pagecard () :
	return self.Mgr.new(null)
