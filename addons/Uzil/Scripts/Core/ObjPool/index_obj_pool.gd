# desc ==========

## 索引 物件池
##
## 重複利用物件
##

# const =========

## 路徑
var PATH : String

# sub_index =====

## 殼
var Shell

# core =====

## 任意物件
var Core_Any

# inst ==========

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("ObjPool")
	
	self.Shell = G.v.Uzil.load_script(self.PATH.path_join("obj_pool_shell.gd"))
	
	# Shell ======
	# 任意
	self.Core_Any = G.v.Uzil.load_script(self.PATH.path_join("obj_pool_core_any.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
	
