# desc ==========

## 索引 Hurt 傷害
##
## 
##

# const ========

## 路徑
var PATH : String

## 腳本路徑
var SCRIPT_PATH : String

# sub_index =====

var Inst
var Bill

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Hurts")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Game.Hurts",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("hurts_inst.gd"))
			self.Bill = Uzil.load_script(self.PATH.path_join("hurts_bill.gd"))
			return self,
		{
			"alias":[&"Hurts"]
		}
	)
	
	UREQ.bind(&"Uzil", &"hurts",
		func():
			var inst = self.Inst.new(self)
			return inst
			,
		{
			"requires":[&"Uzil:Game.Hurts"],
		}
	)
	
	return self
