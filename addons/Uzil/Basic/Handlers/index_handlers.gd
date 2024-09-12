# desc ==========

## 索引 Handlers 處理串
##
## 
## 


# const =========

## 路徑
var PATH : String

# sub_index =====

## 實例
var Inst

## 工具
var Util

# inst ==========

var util

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Handlers")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Basic.Handlers",
		func():
			self.Util = Uzil.load_script(self.PATH.path_join("handlers_util.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("handlers_inst.gd"))
			
			self.util = self.Util.new()
			
			return self,
		{
			"alias":["Handlers"]
		}
	)
	
	UREQ.bind(&"Uzil", &"handlers",
		func():
			var mgr = UREQ.acc(&"Uzil:Util").InstMgr.new(func(key):
				return self.Inst.new(self)
			)
			return mgr,
		{
			"requires" : ["Basic.Handlers"],
		}
	)
	
	return self
