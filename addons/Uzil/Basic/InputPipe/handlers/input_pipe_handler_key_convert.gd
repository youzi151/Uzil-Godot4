
# Variable ===================

var dst_key := 0

var sort := 0

# GDScript ===================

# Extends ====================

# Public =====================

# Interface ==================

## 設置 核心
func set_core (core) :
	pass

## 處理 訊號
func handle_msg (input_msg) :
	
	input_msg.virtual_key = self.dst_key
	
	input_msg.sort = self.sort
	
	return input_msg

## 讀取
func load_memo (_memo : Dictionary) :
	
	if _memo.has("dst") :
		self.dst_key = _memo["dst"]
	
	if _memo.has("srt") :
		self.sort = _memo["srt"]
	elif _memo.has("sort") :
		self.sort = _memo["sort"]

# Private ====================

