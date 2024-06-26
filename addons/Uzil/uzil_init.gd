extends Node

## Uzil 初始化
## 
## 因為需要在autoload中就初始化Uzil, 才能在啟動時對視窗尺寸(預設設為0x0的)做及時調整避免被改為最小64x64.[br]
## 但又不能使Uzil在autoload中固定為常數而無法更新, 所以改由另一個腳本(這裡)來呼叫初始化.
##

# Variable ===================

# GDScript ===================

func _init () :
	self.init()

# Extends ====================

# Public =====================

func init () :
	
	# 釋放先前的
	if G.v.has("Uzil") :
		var uzil_node : Node = G.v.Uzil
		uzil_node.get_parent().remove_child(uzil_node)
		uzil_node.free()
	
	# 讀取並建立 Uzil節點
	var uzil = G.load_script("res://addons/Uzil/uzil.gd").new()
	uzil.name = "Uzil"
	
	# 加為 G節點 子節點
	G.add_child(uzil)
	
	# 初始化
	uzil.init()

# Private ====================
