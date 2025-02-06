
## 實例 管理器
## 
## 管理 實例的取用與建立
## 

# Variable ===================

## 鍵:實例
var key_to_inst : Dictionary = {}

## 新建函式 (僅建立無個體差異的實例)
var create_inst_fn : Callable

## 銷毀函式 (僅銷毀無個體差異的實例)
var destroy_inst_fn : Callable

# GDScript ===================

func _init (create_fn: Callable, destroy_fn: Callable = Callable()) :
	self.create_inst_fn = create_fn
	if not destroy_fn.is_null() :
		self.destroy_inst_fn = destroy_fn

# Extends ====================

# Interface ==================

# Public =====================

## 取用/建立 實例
func inst (key = "") :
	var inst : Object = null
	if not self.key_to_inst.has(key) :
		inst = self.create_inst_fn.call(key)
		self.key_to_inst[key] = inst
	else :
		inst = self.key_to_inst[key]
	return inst

## 銷毀
func del (key) :
	if not self.key_to_inst.has(key) : return
	var inst = self.key_to_inst[key]
	self.key_to_inst.erase(key)
	if not self.destroy_inst_fn.is_null() :
		self.destroy_inst_fn.call(inst)
		
