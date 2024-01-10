
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

## 策略
var _strat = null

# GDScript ===================

func _init (strat) :
	self._strat = strat
	if self._strat.has_method("_set_core") :
		self._strat._set_core(self)
	

# Extends ====================

# Public =====================

## 處理 訊號
func handle_msg (input_msg) :
	if self._strat == null : return input_msg
	if not input_msg.real_key in self.src_keys : return input_msg
	return self._strat.handle_msg(input_msg)

## 讀取
func load_memo (_memo : Dictionary) :
	if _memo.has("src") :
		self.src_keys = _memo["src"]
	
	if self._strat and self._strat.has_method("load_memo") :
		self._strat.load_memo(_memo)
	
