# desc ==========

## 索引 FX 特效管理
##
## 提供簡易 預載, 重用, 回收 特效.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 管理器
var Mgr

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("FX")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Advance.FX",
		func():
			self.Mgr = Uzil.load_script(self.PATH.path_join("fx_mgr.gd"))
			return self,
	)
	
	# 綁定 工具組
	UREQ.bind(&"Uzil", &"fx",
		func():
			return self.Mgr.new(),
		{
			"requires" : ["Advance.FX"],
		}
	)
