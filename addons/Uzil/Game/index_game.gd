# desc ==========

## 索引 Game 遊戲相關
##
## 提供 開發遊戲 會用到的共通功能.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 子索引
var sub_indexes := []

## 傷害
var Hurts

## 附加狀態系統
var Buffs

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Game")
	
	self.Hurts = Uzil.load_script(self.PATH.path_join("Hurts/index_hurts.gd")).new()
	self.sub_indexes.push_back(self.Hurts)
	
	self.Buffs = Uzil.load_script(self.PATH.path_join("Buffs/index_buffs.gd")).new()
	self.sub_indexes.push_back(self.Buffs)
	
	# 建立索引
	for each in self.sub_indexes :
		each.index(Uzil, self)
	
	return self
