
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

## 初始化設置
func setup (runtime, state) :
	pass

## 推進
func process (runtime, state, _dt) :
	pass

## 當 狀態 進入
func on_enter (runtime, state) :
	var data : Dictionary = state.data
	
	var page_card_mgr = UREQ.acc(&"Uzil:page_card_mgr")
	var pagecard_inst = page_card_mgr.inst(data["inst_key"])
	
	var page = pagecard_inst.get_page(data["page"])
	if page == null : return
	
	var combo : String = data["combo"] if data.has("combo") else ""
	var query : String = data["query"] if data.has("query") else ""
	
	if combo != "" or not query.is_empty() :
		page.combo(combo)
	else :
		page.query(query)
		
	pagecard_inst.refresh()

## 當 狀態 離開
func on_exit (runtime, state) :
	pass


# Public =====================

# Private ====================
