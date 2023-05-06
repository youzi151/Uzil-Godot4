# desc ==========

## 索引 Core 核心
##
## 底層核心功能類型, 受其他上層功能類型所使用.
##

# const ========

## 路徑
var PATH : String

# sub_index =====

## 子索引
var sub_indexes := []

## 呼叫器
var Invoker
## 事件
var Evt
## 時間
var Times
## 物件池
var ObjPool
## 變數庫
var Vars
## 多重數值
var Vals
## 總結數值
var SumVals

# inst ==========

# other =========

# func ==========

func _init () :
	pass

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Core")
	
	# class
	self.Vals = G.v.Uzil.load_script(self.PATH.path_join("vals.gd"))
	
	# sub index
	self.Invoker = G.v.Uzil.load_script(self.PATH.path_join("Invoker/index_invoker.gd")).new()
	self.sub_indexes.push_back(self.Invoker)
	
	self.Times = G.v.Uzil.load_script(self.PATH.path_join("Times/index_times.gd")).new()
	self.sub_indexes.push_back(self.Times)
	
	self.Evt = G.v.Uzil.load_script(self.PATH.path_join("Evt/index_evt.gd")).new()
	self.sub_indexes.push_back(self.Evt)
	
	self.ObjPool = G.v.Uzil.load_script(self.PATH.path_join("ObjPool/index_obj_pool.gd")).new()
	self.sub_indexes.push_back(self.ObjPool)
	
	self.Vars = G.v.Uzil.load_script(self.PATH.path_join("Vars/index_vars.gd")).new()
	self.sub_indexes.push_back(self.Vars)
	
	self.SumVals = G.v.Uzil.load_script(self.PATH.path_join("SumVals/index_sum_vals.gd")).new()
	self.sub_indexes.push_back(self.SumVals)
	
	## 建立索引
	for each in self.sub_indexes :
		each.index(self)
		
	return self

## 初始化
func init (_parent_index) :
	
	## 初始化
	for each in self.sub_indexes :
		each.init(self)
		
	return self
