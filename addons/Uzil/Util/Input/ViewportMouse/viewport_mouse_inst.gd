
# Variable ===================

## 視圖
var viewport : Viewport = null

## 位置
var pos : Vector2 = Vector2.ZERO


# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 設置 位置
func set_position (pos: Vector2) :
	self.pos = pos

## 取得 位置
func get_position () :
	return self.pos

## 設置 視圖
func set_viewport (_viewport: Viewport) :
	self.viewport = _viewport

## 取得 視圖
func get_viewport () :
	return self.viewport

# Private ====================
