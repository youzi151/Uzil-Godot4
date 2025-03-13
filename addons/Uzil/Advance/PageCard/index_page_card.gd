# desc ==========

## 索引 PageCard 頁面卡
##
## 透過指定頁面來開關對應的卡片(物件).[br]
## 也可在編輯器中操作設置所有頁面與卡片.
## 

# const =========

## 路徑
var PATH : String

## 查詢模式
enum QueryMode {
	# 資訊
	INFO,
	# 顯示
	SHOW,
	# 隱藏
	HIDE,
	# 顯示 否則 清除
	SHOW_OR_CLEAR,
	# 隱藏 否則 清除
	HIDE_OR_CLEAR,
	# 顯示 否則 隱藏
	SHOW_OR_HIDE,
}

# sub_index =====

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
	
	self.PATH = _parent_index.PATH.path_join("PageCard")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Advance.PageCard",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("page_card_inst.gd"))
			self.Page = Uzil.load_script(self.PATH.path_join("page_card_page.gd"))
			self.Card = Uzil.load_script(self.PATH.path_join("page_card_card.gd"))
			, 
		{
			"alias" : ["PageCard"]
		}
	)
	
	# 綁定 管理
	UREQ.bind(&"Uzil", &"page_card_mgr", 
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Inst.new(),
			)
			Uzil.request_node("Advance/PageCard", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : ["page_card", "pagecard"],
			"requires" : ["Util", "Advance.PageCard"],
		}
	)
	
	return self
