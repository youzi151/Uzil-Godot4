# desc ==========

## 索引 TagSearch 標籤檢索
##
## 標籤檢索系統, tag可帶有negative, scope, attr屬性.[br]
## 可定義 如: %&/role:tank表示 角色定位 的 坦 tag, 並帶有 % 與 & 標記 供外部用途使用 [br]
## 可檢索 如: role:tank, -element:fire aqua 表示 搜尋 角色定位的坦 且 避免搜尋 火 水 屬性 [br]
## 

# const =========

## 路徑
var PATH : String

## 設定
var Config
## 實體
var Inst
## 管理
var Mgr

# sub_index =====

# inst ==========

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("TagSearch")
	
	self.Config = G.v.Uzil.load_script(self.PATH.path_join("tag_search_config.gd"))
	
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("tag_search_inst.gd"))
	
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("tag_search_mgr.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
