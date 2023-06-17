
## i18n handler vars 在地化 處理器 變數
##
## 從 Vars 中 取得變數 來 替換關鍵字.
##

var vars

# Variable ===================

## 正則式
var regex_pattern := "<\\$([^<>\\$]*)\\$>"

## 正則
var regex : RegEx = null

## 當 不存在時 替代
var replace_when_not_found = null

# GDScript ===================

func _init () :
	self.vars = UREQ.access_g("Uzil", "vars")
	self.regex = RegEx.new()
	self.regex.compile(self.regex_pattern)

# Interface ==================

## 處理 翻譯
func handle (trans_task) :
	# 搜尋
	var matches := self.regex.search_all(trans_task.text)
#	print("[i18n_handler_vars.handle()] matches %d" % matches.size())
	
	# 若 沒有找到 則 返回
	if matches.size() == 0 :
		return false
	
	# 是否有替換
	var is_trans := false
	
	# 已經替換過的鍵
	var replaced_keys := []
	
	# 每個 搜尋結果
	for each in matches :
		
		# 變數庫 實體鍵
		var inst_key = ""
		# 鍵
		var key : String
		
		# 完整鍵
		var full_key : String = each.get_string(1)
		# 拆分成 實體鍵 與 鍵
		var inst_to_key : PackedStringArray = full_key.split(":")
		
		# 若 沒有2個 則 視為 鍵
		if inst_to_key.size() < 2 :
			key = inst_to_key[0]
		# 若 有2個 則
		else : 
			# 取得 實體鍵
			inst_key = inst_to_key[0]
			# 取得 鍵
			key = inst_to_key[1]
		
		# 若 已替換過 則 忽略
		if replaced_keys.has(full_key) : break
		
		# 完整字串
		var full_str : String = each.get_string(0)
		
		# 要替換成的文字 從指定變數庫中取得
		var replace = self.vars.inst(inst_key).get_var(key)
		
		# 若 要替換成的文字不存在
		if replace == null :
			# 若有 預設替換文字 則 使用
			if self.replace_when_not_found != null :
				replace = self.replace_when_not_found
			# 否則 不替換
			else :
				continue
		
		# 替換文字
#		print("[i18n_handler_vars.handle()] replace \"%s\" to \"%s\"" % [full_str, replace])
		trans_task.text = (trans_task.text as String).replace(full_str, str(replace))
		
		# 紀錄 已替換過
		replaced_keys.push_back(full_key)
		is_trans = true
	
	return is_trans

# Public =====================

# Private ====================

