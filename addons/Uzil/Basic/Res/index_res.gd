# desc ==========

## 索引 Res 資源管理
##
## 以 持有資源 來達到即使不被引用, 資源仍可存在的管理效果.
## 若有需要特殊的讀取資源方式, 也可添加 自訂資源讀取器 到 實體.
## 

# const =========

## 路徑
var PATH : String

## 實體
var Inst

## 資源資訊
var Info

# sub_index =====

# inst ==========

## 實體
var _inst

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Res")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Basic.Res",
		func () :
			
			self.Inst = Uzil.load_script(self.PATH.path_join("res_inst.gd"))
			self.Info = Uzil.load_script(self.PATH.path_join("res_info.gd"))
				
			return self, 
		{
			"alias" : ["Res"],
		}
	)
	
	# 綁定 實體
	UREQ.bind("Uzil", "res", 
		func () :
			var inst = self.Inst.new()
			inst.name = "res"
			Uzil.add_child(inst)
			return inst,
		{
			"alias" : ["res_mgr", "res_inst"],
			"requires" : ["Basic.Res"],
		}
	)
	
	return self

