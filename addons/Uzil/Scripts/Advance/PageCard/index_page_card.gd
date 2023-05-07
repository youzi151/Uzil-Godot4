# desc ==========

## 索引 PageCard 頁面卡
##
## 透過指定頁面來開關對應的卡片(物件).[br]
## 也可在編輯器中操作設置所有頁面與卡片.
## 

# const =========

## 路徑
var PATH : String

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

## 管理器
var mgr

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("PageCard")
	
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("page_card_mgr.gd"))
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("page_card_inst.gd"))
	self.Page = G.v.Uzil.load_script(self.PATH.path_join("page_card_page.gd"))
	self.Card = G.v.Uzil.load_script(self.PATH.path_join("page_card_card.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	
	self.mgr = self.Mgr.new()
	
	return self
	
