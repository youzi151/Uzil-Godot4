
## 實例 管理器
## 
## 管理 實例的取用與建立
## 

# Variable ===================

## 鍵:實例
var key_to_inst : Dictionary = {}

## 新建函式 (僅建立無個體差異的實例)
var create_inst_fn : Callable

# GDScript ===================

func _init (create_fn : Callable) :
	self.create_inst_fn = create_fn

# Extends ====================

# Interface ==================

# Public =====================

## 取用/建立 實例
func inst (key) :
	var inst : Object = null
	if not self.key_to_inst.has(key) :
		inst = self.create_inst_fn.call()
		self.key_to_inst[key] = inst
	else :
		inst = self.key_to_inst[key]
	return inst
