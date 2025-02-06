extends Node

## 實例 管理器
## 
## 管理 實例的取用與建立
## 

# Variable ===================

var mgr

# GDScript ===================

func _init (mgr) :
	self.mgr = mgr

func _process (_dt: float) :
	for each in self.mgr.key_to_inst.values() :
		each.process(_dt)

# Extends ====================

# Interface ==================

# Public =====================
