
var bitmap_start : int = 54

var resolution : int = 2834

## 將圖像作為 BMP 檔保存到一個位元組陣列
func save_bmp_to_buffer (width: int, height: int, color_arr: Array) :
	var padded_row_size : int = (3*width)
	var padding : int = padded_row_size % 4
	if padding > 0 : padding = 4 - padding
	padded_row_size += padding
	
	var bitmap_size : int = padded_row_size * height
	var file_size : int = bitmap_start + bitmap_size
	
	var bmp_buffer : PackedByteArray = PackedByteArray()
	bmp_buffer.resize(bitmap_start)
	
	# Signature bm
	bmp_buffer[0x0] = 0x42
	bmp_buffer[0x1] = 0x4d
	# file size
	bmp_buffer[0x2] = (file_size) & 0xff
	bmp_buffer[0x3] = (file_size >> (8*1)) & 0xff
	bmp_buffer[0x4] = (file_size >> (8*2)) & 0xff
	bmp_buffer[0x5] = (file_size >> (8*3)) & 0xff
	# reserved
	# data offset
	bmp_buffer[0xA] = 0x36 # 54
	# info header size
	bmp_buffer[0xE] = 0x28 # 40
	# width
	bmp_buffer[0x12] = (width) & 0xff
	bmp_buffer[0x13] = (width >> (8*1)) & 0xff
	bmp_buffer[0x14] = (width >> (8*2)) & 0xff
	bmp_buffer[0x15] = (width >> (8*3)) & 0xff
	# height
	bmp_buffer[0x16] = (height) & 0xff
	bmp_buffer[0x17] = (height >> (8*1)) & 0xff
	bmp_buffer[0x18] = (height >> (8*2)) & 0xff
	bmp_buffer[0x19] = (height >> (8*3)) & 0xff
	# planes
	bmp_buffer[0x1A] = 0x01 # 1
	# bits per pixel
	bmp_buffer[0x1C] = 0x18 # 24
	# image size
	bmp_buffer[0x22] = (bitmap_size) & 0xff
	bmp_buffer[0x23] = (bitmap_size >> (8*1)) & 0xff
	bmp_buffer[0x24] = (bitmap_size >> (8*2)) & 0xff
	bmp_buffer[0x25] = (bitmap_size >> (8*3)) & 0xff
	# x resolution
	#bmp_buffer[0x26] = (resolution) & 0xff
	#bmp_buffer[0x27] = (resolution >> (8*1)) & 0xff
	#bmp_buffer[0x28] = (resolution >> (8*2)) & 0xff
	#bmp_buffer[0x29] = (resolution >> (8*3)) & 0xff
	# y resolution
	#bmp_buffer[0x2A] = (resolution) & 0xff
	#bmp_buffer[0x2B] = (resolution >> (8*1)) & 0xff
	#bmp_buffer[0x2C] = (resolution >> (8*2)) & 0xff
	#bmp_buffer[0x2D] = (resolution >> (8*3)) & 0xff
	
	var content_buffer : PackedByteArray = PackedByteArray()
	content_buffer.resize(padded_row_size * height)
	for h in height :
		var revert_h : int = height - 1 - h
		for w in width :
			var idx : int = (width * h) + w
			var color : Color = color_arr[idx]
			#var color : Color = img.get_pixel(w, h)
			var buffer_idx : int = (padded_row_size*revert_h) + (w * 3)
			content_buffer[buffer_idx] = int(color.b8) & 0xff
			content_buffer[buffer_idx+1] = int(color.g8) & 0xff
			content_buffer[buffer_idx+2] = int(color.r8) & 0xff
	
	bmp_buffer.append_array(content_buffer)
	
	return bmp_buffer
