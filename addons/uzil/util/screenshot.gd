## ScreenShot 擷圖相關
##
## 擷取 viewport 當前顯示 為 圖像資料
##

# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

func get_png_buffer (viewport: Viewport, options := {}) :
	
	var image : Image = viewport.get_texture().get_image()
	if "size" in options :
		var size : Vector2 = options["size"]
		image = image.duplicate()
		image.resize(size.x, size.y)
	return image.save_png_to_buffer()
	
func get_jpg_buffer (viewport: Viewport, options := {}) :
	
	var image : Image = viewport.get_texture().get_image()
	
	if "size" in options :
		var size : Vector2 = options["size"]
		image = image.duplicate()
		image.resize(size.x, size.y)
	
	var quality : float = 7.5
	if "quality" in options :
		quality = options["quality"]
	
	return image.save_jpg_to_buffer(quality)

# Private ====================

