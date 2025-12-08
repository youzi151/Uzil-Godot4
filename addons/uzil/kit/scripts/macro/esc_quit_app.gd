extends Node

# Variable ===================

## 是否應用於網頁
@export
var is_apply_on_web := false

# GDScript ===================

func _process (_dt: float) :
	pass

func _unhandled_input(event):
	# 忽略 非鍵盤事件
	if not (event is InputEventKey) : return
	# 忽略 非按下 非esc
	if not event.pressed or event.keycode != KEY_ESCAPE : return
	# 若 關閉應用於網頁 且 該發布為網頁 則 忽略
	if not self.is_apply_on_web and OS.has_feature("web") : return
	
	get_tree().quit()
	
	

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

