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
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Core")
	
	# class
	self.Vals = Uzil.load_script(self.PATH.path_join("Vals/vals.gd"))
		
	# 綁定 索引 多重變數
	UREQ.bind("Uzil", "Core.Vals", self.Vals, {
		"alias" : ["Vals"]
	})
	
	# sub index
	self.Times = Uzil.load_script(self.PATH.path_join("Times/index_times.gd")).new()
	self.sub_indexes.push_back("Times")
	
	self.Invoker = Uzil.load_script(self.PATH.path_join("Invoker/index_invoker.gd")).new()
	self.sub_indexes.push_back("Invoker")
	
	self.Evt = Uzil.load_script(self.PATH.path_join("Evt/index_evt.gd")).new()
	self.sub_indexes.push_back("Evt")
	
	self.ObjPool = Uzil.load_script(self.PATH.path_join("ObjPool/index_obj_pool.gd")).new()
	self.sub_indexes.push_back("ObjPool")
	
	self.Vars = Uzil.load_script(self.PATH.path_join("Vars/index_vars.gd")).new()
	self.sub_indexes.push_back("Vars")
	
	self.SumVals = Uzil.load_script(self.PATH.path_join("SumVals/index_sum_vals.gd")).new()
	self.sub_indexes.push_back("SumVals")
	
	## 建立索引
	for each in self.sub_indexes :
		self[each].index(Uzil, self)
	
	return self
