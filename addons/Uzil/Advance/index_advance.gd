# desc ==========

## 索引 Advance 進階
##
## 使用基本與核心的功能, 來進行特定應用.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 子索引
var sub_indexes := []

## 音效
var Audio
## 特效
var FX
## 設定
var Options
## 頁面卡系統
var PageCard
## 狀態機
var States
## UI導航
var UINav
## 字典資料庫
var DictDB
## 初始化
var Init

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Advance")
	
	self.Audio = Uzil.load_script(self.PATH.path_join("Audio/index_audio.gd")).new()
	self.sub_indexes.push_back(self.Audio)
	
	self.FX = Uzil.load_script(self.PATH.path_join("FX/index_fx.gd")).new()
	self.sub_indexes.push_back(self.FX)
	
	self.Options = Uzil.load_script(self.PATH.path_join("Options/index_options.gd")).new()
	self.sub_indexes.push_back(self.Options)
	
	self.PageCard = Uzil.load_script(self.PATH.path_join("PageCard/index_page_card.gd")).new()
	self.sub_indexes.push_back(self.PageCard)
	
	self.States = Uzil.load_script(self.PATH.path_join("States/index_states.gd")).new()
	self.sub_indexes.push_back(self.States)
	
	self.UINav = Uzil.load_script(self.PATH.path_join("UINav/index_ui_nav.gd")).new()
	self.sub_indexes.push_back(self.UINav)
	
	self.DictDB = Uzil.load_script(self.PATH.path_join("DictDB/index_dict_db.gd")).new()
	self.sub_indexes.push_back(self.DictDB)
	
	self.Init = Uzil.load_script(self.PATH.path_join("Init/index_init.gd")).new()
	self.sub_indexes.push_back(self.Init)
	
	# 建立索引
	for each in self.sub_indexes :
		each.index(Uzil, self)
	
	return self
