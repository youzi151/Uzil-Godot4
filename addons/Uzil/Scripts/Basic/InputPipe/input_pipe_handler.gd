
## InputPipe.Handler 輸入管道 處理者
##
## 紀錄 需要偵測的來源key(實際輸入)
## 以及 將 來源key的訊號 轉換為 不同key或不同值 存回訊號 中
## 


# Variable ===================

## 辨識
var id := ""

## 來源key
var src_keys := []

## 核心
var _core = null

# GDScript ===================

func _init (core) :
	self._core = core
	if self._core.has_method("_set_shell") :
		self._core._set_shell(self)
	

# Extends ====================

# Public =====================

## 處理 訊號
func handle_msg (input_msg) :
	if self._core == null : return input_msg
	return self._core.handle_msg(input_msg)

## 讀取
func load_memo (_memo : Dictionary) :
	if _memo.has("src") :
		self.src_keys = _memo["src"]
		
	if self._core and self._core.has_method("load_memo") :
		self._core.load_memo(_memo)
	
