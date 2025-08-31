
## i18n handler format 在地化 處理器 格式化
##
## string.format({}) or string % []
##

# Variable ===================

# GDScript ===================

# Interface ==================

## 取得 名稱
func get_name () :
	return "FORMAT"

## 處理 翻譯
func handle (trans_task) :
	if trans_task.format != null :
		var is_trans := false
		var last_text : String = trans_task.text
		match typeof(trans_task.format) :
			TYPE_DICTIONARY :
				trans_task.text = trans_task.text.format(trans_task.format)
			TYPE_ARRAY :
				trans_task.text = trans_task.text % trans_task.format
		if last_text != trans_task.text :
			is_trans = true
		
		return is_trans

# Public =====================

# Private ====================
