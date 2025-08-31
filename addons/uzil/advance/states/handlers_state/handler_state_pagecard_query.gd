
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
	
	var dict_util = UREQ.acc(&"Uzil:Util").dict
	
	var page_card_mgr = UREQ.acc(&"Uzil:page_card_mgr")
	var pagecard_inst_key : String = dict_util.get_with_fallbacks(data, ["pagecard_query.inst_key", "inst_key"], "")
	var pagecard_inst = page_card_mgr.inst(pagecard_inst_key)
	
	var page_id = dict_util.get_with_fallbacks(data, ["pagecard_query.page", "page"], "")
	if page_id == null : return
	
	var page = pagecard_inst.get_page(page_id)
	if page == null : return
	
	var combo : String = dict_util.get_with_fallbacks(data, ["pagecard_query.combo", "combo"], "")
	var query : String = dict_util.get_with_fallbacks(data, ["pagecard_query.query", "query"], "")
	
	if not combo.is_empty():
		page.combo(combo)
	else :
		page.query(query)
		
	pagecard_inst.refresh()

## 當 狀態 離開
func on_exit (runtime, state) :
	pass


# Public =====================

# Private ====================
