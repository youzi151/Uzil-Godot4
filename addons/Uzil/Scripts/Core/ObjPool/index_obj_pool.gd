# desc ==========

## 索引 物件池
##
## 重複利用物件
##

# const =========

## 路徑
var PATH : String

# sub_index =====

## 殼
var Shell

# core =====

## 任意物件
var Core_Any

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("ObjPool")
	
	# 綁定 索引
	UREQ.bind_g("Uzil", "Core.ObjPool",
		func () :
			# Shell =====
			
			self.Shell = Uzil.load_script(self.PATH.path_join("obj_pool_shell.gd"))
			
			# Core ======
			
			# 任意
			self.Core_Any = Uzil.load_script(self.PATH.path_join("obj_pool_core_any.gd"))
			
			return self,
		{
			"alias" : ["ObjPool"]
		}
	)
	
	return self

