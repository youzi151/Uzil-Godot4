# desc ==========

## 索引 Basic 基本
##
## 基本功能類型, 用途廣泛
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 子索引
var sub_indexes := []

# inst ==========

## 流程
var Flow
## 輸入操作
var InputPipe
## 用戶存檔
var UserSave
## 在地化
var I18N
## 標籤檢索
var TagQ


# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Basic")
	
	self.UserSave = Uzil.load_script(self.PATH.path_join("UserSave/index_user_save.gd")).new()
	self.sub_indexes.push_back(self.UserSave)
	
	self.InputPipe = Uzil.load_script(self.PATH.path_join("InputPipe/index_input_pipe.gd")).new()
	self.sub_indexes.push_back(self.InputPipe)
	
	self.Flow = Uzil.load_script(self.PATH.path_join("Flow/index_flow.gd")).new()
	self.sub_indexes.push_back(self.Flow)
	
	self.I18N = Uzil.load_script(self.PATH.path_join("I18N/index_i18n.gd")).new()
	self.sub_indexes.push_back(self.I18N)
	
	self.TagQ = Uzil.load_script(self.PATH.path_join("TagQ/index_tag_q.gd")).new()
	self.sub_indexes.push_back(self.TagQ)
	
	# 建立索引
	for each in self.sub_indexes :
		each.index(Uzil, self)
		
	return self
