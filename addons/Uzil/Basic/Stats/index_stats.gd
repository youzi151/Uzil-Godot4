# desc ==========

## 索引 Stats 統計
##
## 
## 


# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Inst

## 資料
var Data

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Stats")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Basic.Stats",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("stats_inst.gd"))
			self.Data = Uzil.load_script(self.PATH.path_join("stats_data.gd"))
			return self,
		{
			"alias":["Stats"]
		}
	)
	
	return self
