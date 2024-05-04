# desc ==========

## 索引 SumVals 總結算值
##
## 每筆資料持有多個子資料, 可依照自身的值 與 子資料 的 總結算值 進行 總結算.[br]
## 透過不同的路由, 可建立與取得不同階層的資料.
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
	
	self.PATH = _parent_index.PATH.path_join("SumVals")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Core.SumVals",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("sum_vals_inst.gd"))
			self.Data = Uzil.load_script(self.PATH.path_join("sum_vals_data.gd"))
			return self,
		{
			"alias":["SumVals"]
		}
	)
	
	return self
