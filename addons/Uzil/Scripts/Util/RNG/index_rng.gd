# desc ==========

## 索引 RNG 隨機數
##
## 提供不同方式的隨機數產生器
##

# const =========

## 路徑
var PATH : String

# sub_index =====

# inst ==========

## 比率隨機
var Rate
## 池隨機
var Pool

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("RNG")
	
	self.Pool = G.v.Uzil.load_script(self.PATH.path_join("rng_pool.gd"))
	self.Rate = G.v.Uzil.load_script(self.PATH.path_join("rng_rate.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
