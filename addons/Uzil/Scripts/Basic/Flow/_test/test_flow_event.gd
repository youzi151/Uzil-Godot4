
# Variable ===================

var msg := ""

# GDScript ===================

# Extends ====================

# 當 初始化 
func _on_init (_init_data) :
	pass

# 讀取 紀錄
func _load_memo (_memo : Dictionary) :
	if _memo.has("msg") :
		self.msg = _memo["msg"]

# 匯出 紀錄
func _to_memo (_memo : Dictionary, _args) :
	_memo["msg"] = self.msg
	return _memo

# 進入
func _on_enter () :
	print("test event works!")
	var memo = G.v.Uzil.flow.inst().to_memo()
	print(memo)
#	memo.chains["a_chain"]["state"] = 1
	G.v.Uzil.flow.inst().load_memo(memo)

# 離開
func _on_exit () :
	pass

# Public =====================

# Private ====================
