
## i18n handler func 在地化 處理器 函式
##
## 執行 函式 並依照 回傳值 來 代換 關鍵字.[br]
## 因為有執行順序的問題, 所以使用預先儲存要替換的字串,並再統一format來代換.
##


# Variable ===================

## 正則式
var regex_pattern := "<\\^([^<>\\^]*)\\^>"

## 正則
var regex : RegEx = null

## 暫時替換用的字元
var temp_replace_char : String = "\ufffe"

## 當 不存在時 替代
var replace_when_not_found = null

# GDScript ===================

func _init () :
	self.regex = RegEx.new()
	self.regex.compile(self.regex_pattern)

# Interface ==================

## 處理 翻譯
func handle (trans_task) :
	# 搜尋
	var matches = self.regex.search_all(trans_task.text)
	
	# 若 沒有找到 則 返回
	if matches.size() == 0 :
		return false
	
	# 是否有替換
	var is_trans = false
	
	# 要替換的文字
	var to_replaces := []
	
	# 因為要使用format 所以先把 % 轉換為 替代符號
	trans_task.text = trans_task.text.replace("%", self.temp_replace_char)
	
	# 每個 搜尋結果
	for each in matches :
		
		# 完整字串
		var full_str = each.get_string(0)
		# 鍵
		var key = each.get_string(1)
		
		# 找到 該鍵 對應的 函式
		var fn = trans_task.inst.get_func(key)
		
		# 要替換成的文字
		var replace
		
		# 若 函式 存在 則 呼叫 並取得要替換的文字
		if fn != null :
			replace = fn.call()
			
		# 若 要替換成的文字不存在
		if replace == null :
			# 若有 預設替換文字 則 使用
			if self.replace_when_not_found != null :
				replace = self.replace_when_not_found
			# 否則 不替換
			else :
				continue
				
		# 加入 要替換的文字
		to_replaces.push_back(replace)
		# 預備先替換成 代換字
		replace = "%s"
			
		# 代換 文字
		trans_task.text = (trans_task.text as String).replace(full_str, replace)
		
		# 紀錄 已替換過
		is_trans = true
	
	# 若 已替換過 則 倒入 所有要替換的文字
	if is_trans :
		trans_task.text = trans_task.text % to_replaces
	
	# 把 替代符號 轉換回 %
	trans_task.text = trans_task.text.replace(self.temp_replace_char, "%")
	
	return is_trans

# Public =====================

# Private ====================

