
# desc ==========

## 索引 Vars 變數集合
## 
## 自由存取變數以及附加功能
##

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Inst
## 管理
var Mgr

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Vars")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Core.Vars", 
		func () :
			self.Inst = Uzil.load_script(self.PATH.path_join("vars_inst.gd"))
			self.Mgr = Uzil.load_script(self.PATH.path_join("vars_mgr.gd"))
			return self,
		{
			"alias" : ["Vars"]
		}
	)
	
	# 綁定 實體管理
	UREQ.bind("Uzil", "vars_mgr",
		func () :
			return self.Mgr.new(),
		{
			"alias" : ["vars"],
			"requires" : ["Core.Vars"],
		}
	)
	
	return self

