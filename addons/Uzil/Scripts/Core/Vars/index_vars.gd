
# desc ==========

## 索引 Vars 變數集合
## 
## 自由存取變數以及附加功能
##

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Inst
## 管理
var Mgr

# inst ==========

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Vars")
	
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("vars_inst.gd"))
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("vars_mgr.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
