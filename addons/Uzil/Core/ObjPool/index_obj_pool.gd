# desc ==========

## 索引 物件池
##
## 重複利用物件
##

# const =========

## 路徑
var PATH : String

# sub_index =====

## 核心
var Core

# 策略 =====

## 預製物件
var Strat_Prefab

## 任意物件
var Strat_Any

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("ObjPool")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.ObjPool",
		func():
			# 核心 =====
			
			self.Core = Uzil.load_script(self.PATH.path_join("obj_pool_core.gd"))
			
			# 策略 ======
			
			# 任意
			self.Strat_Any = Uzil.load_script(self.PATH.path_join("obj_pool_strat_any.gd"))
			self.Strat_Prefab = Uzil.load_script(self.PATH.path_join("obj_pool_strat_prefab.gd"))
			
			return self,
		{
			"alias" : ["ObjPool"]
		}
	)
	
	return self

