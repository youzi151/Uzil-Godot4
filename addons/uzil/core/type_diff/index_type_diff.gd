# desc ==========

## 索引 TypeDiff 類型比對
##
## 檢查 對象(字典或物件) 是否符合定義(有指定方法或成員).
##

# const =========

## Uzil
var Uzil

## 路徑
var PATH : String

# sub_index =====

## 實體
var Inst

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.Uzil = Uzil
	self.PATH = _parent_index.PATH.path_join("type_diff")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.TypeDiff",
		func () :
			self.Inst = self.Uzil.load_script(self.PATH.path_join("type_diff_inst.gd"))
			return self
			,
		{
			"alias" : ["TypeDiff"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind(&"Uzil", &"type_diff_mgr",
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Inst.new(key)
			)
			self.Uzil.request_node("Core/TypeDiff", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : ["type_diff_mgr"],
			"requires" : ["Core.TypeDiff"],
		}
	)
	
	# 綁定 實體
	UREQ.bind(&"Uzil", &"type_diff", 
		func():
			var mgr = UREQ.acc(&"Uzil:type_diff_mgr")
			return mgr.inst(),
		{
			"alias" : [],
			"requires" : ["type_diff_mgr"],
		}
	)
	
	return self
