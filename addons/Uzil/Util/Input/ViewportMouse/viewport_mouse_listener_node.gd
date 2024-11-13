extends Node

# Variable ===================

## 滑鼠位置 (本地)
var _mouse_pos : Vector2 = Vector2.ZERO

# GDScript ===================

## 輸入 (蒐集資訊)
func _input (event: InputEvent) :
	if not (event is InputEventMouse) :
		return
	
	self._mouse_pos = event.position
	
	# 設置 到 此節點所在視圖 的 對應實例
	UREQ.acc(&"Uzil:Util").input.viewport_mouse.in_viewport(self.get_viewport()).set_position(self._mouse_pos)

# Extends ====================

# Interface ==================

# Public =====================

## 取得 滑鼠位置
func get_position () :
	return self._mouse_pos

# Private ====================
