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
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("RNG")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Util.RNG",
		func () :
			self.Pool = Uzil.load_script(self.PATH.path_join("rng_pool.gd"))
			self.Rate = Uzil.load_script(self.PATH.path_join("rng_rate.gd"))
			return self, 
		{
			"alias" : ["RNG"],
		}
	)
	
	# 綁定 池隨機 管理
	UREQ.bind("Uzil", "rng_pool_mgr",
		func () :
			var mgr = UREQ.acc("Uzil", "Util").InstMgr.new(func():
				return UREQ.acc("Uzil", "Util.RNG").Pool.new()
			)
			return mgr,
		{
			"alias" : [],
			"requires" : ["Util", "Util.RNG"],
		}
	)
	
	return self
