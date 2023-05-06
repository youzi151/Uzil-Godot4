
## Vars.Mgr 變數庫 實體 管理
##
## 以key取得/建立 變數庫 實體
##

# Variable ===================

## key:實體 表
var key_to_inst := {}

## 預設 實體
var _default_inst = null

# GDScript ===================

func _init () :
	self._default_inst = self.inst("default")

# Public =====================

## 取得 實體
func inst (key := "") :
	if key == "" :
		return self._default_inst
		
	if self.key_to_inst.has(key) :
		return self.key_to_inst[key]
	else:
		var _inst = G.v.Uzil.Core.Vars.Inst.new()
		self.key_to_inst[key] = _inst
		return _inst

# Private ====================
