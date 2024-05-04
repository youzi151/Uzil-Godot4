
## Vars.Mgr 變數庫 實體 管理
##
## 以key取得/建立 變數庫 實體
##

# Variable ===================

## key:實體 表
var key_to_inst := {}

# GDScript ===================

# Public =====================

## 取得 實體
func inst (key := "_") :
	if self.key_to_inst.has(key) :
		return self.key_to_inst[key]
	else:
		var Vars = UREQ.acc("Uzil", "Core.Vars")
		var _inst = Vars.Inst.new()
		self.key_to_inst[key] = _inst
		return _inst

# Private ====================
