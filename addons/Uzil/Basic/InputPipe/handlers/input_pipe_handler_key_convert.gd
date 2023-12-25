
# Variable ===================

var dst_key := 0

# GDScript ===================

# Extends ====================

# Public =====================

# Interface ==================

## 處理 訊號
func handle_msg (input_msg) :
	
	input_msg.virtual_key = self.dst_key
	
	return input_msg

## 讀取
func load_memo (_memo : Dictionary) :
	
	if _memo.has("dst") :
		self.dst_key = _memo["dst"]

# Private ====================

