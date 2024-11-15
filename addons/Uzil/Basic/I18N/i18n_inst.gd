
## i18n inst 實體
##
## 1. 設置 語言資料 [br]
## 2. 設置 多個翻譯器 [br]
## 3. 依照設置 將 傳入的字串 經過多個翻譯器 來 代換字串 [br]
## 4. 發送 語言更換 或 其他更新 事件 給 已經註冊的 偵聽者
##

var I18N

# Variable ===================

## 當前語言
var _current_lang : String = ""

## 當前備選語言
var _current_fallback_langs := []

## 語言
var _code_to_lang := {}

## 鍵:呼叫
var _key_to_func := {}

## 翻譯器
var _translators := []

## 當 語言切換
var _on_language_changed : Object = null

## 當 更新
var _on_update = null

# GDScript ===================

func _init () :
	
	self.I18N = UREQ.acc(&"Uzil:Basic.I18N")
	
	var Evt = UREQ.acc(&"Uzil:Core.Evt")
	
	# 當 語言切換
	self._on_language_changed = Evt.Inst.new()
	# 當 更新
	self._on_update = Evt.Inst.new()

# Extends ====================

# Public =====================

## 更新
func update (evt_options = null) :
	self._on_update.emit(null, evt_options)

## 讀取 所有語言資料
func load_languages (langs_dir_path) :
	var I18N = UREQ.acc(&"Uzil:Basic.I18N")
	self._code_to_lang = I18N.loader.load_langs(langs_dir_path)

## 取得 語言資料
func get_language (code_or_alias) :
	# 若 有 直接對應 則 返回
	if self._code_to_lang.has(code_or_alias) :
		return self._code_to_lang[code_or_alias]
		
	# 作為 別名 查找 所有語言
	for key in self._code_to_lang :
		var each = self._code_to_lang[key]
		if each.alias.has(code_or_alias) :
			return each
		
	return null

## 取得 當前 語言資料
func get_current_language_code () :
	return self._current_lang
func get_current_language () :
	return self.get_language(self._current_lang)

## 取得 當前 所有 備選 語言資料
func get_current_fallback_language_codes () :
	return self._current_fallback_langs
func get_current_fallback_languages () :
	var res : Array = []
	for each in self._current_fallback_langs :
		var each_lang = self.get_language(each)
		if each_lang != null :
			res.push_back(each_lang)
	return res

## 變更語言
## 會卸載所有當前語言的字典, 且只有下個語言的預設目錄中的字典檔案會被讀取.
## 若有手動讀取其他字典則需要注意.
func change_language (_lang_code = null) :
	if _lang_code == null : _lang_code = self.get_current_language_code()
	
	# 取得 該語言
	var i18n_lang = self.get_language(_lang_code)
	
	# 紀錄 前次 語言 與 備選語言
	var last_lang = self.get_language(self._current_lang)
	var last_fallback_langs = self._current_fallback_langs
	
	# 設置 當前 語言 與 備選語言
	self._current_lang = _lang_code
	self._current_fallback_langs.clear()
	
	# 要 讀取字典 的 語言(代號)
	var to_load_code := []
	# 要 卸載字典 的 語言(代號)
	var to_unload_code := []
	
	# 若 目標語言 存在
	if i18n_lang != null :
		
		# 加入 當前語言 至 讀取列表
		to_load_code.push_back(i18n_lang.code)
		
		# 當前語言 的 所有 備選語言(代號)
		for fallback_code in i18n_lang.fallback_langs :
			
			# 加入 備選語言
			self._current_fallback_langs.push_back(fallback_code)
			
			# 加入 備選語言 至 讀取列表	
			to_load_code.push_back(fallback_code)
	
	# 若 前個語言 存在
	if last_lang != null :
		
		# 加入 前個語言 到 卸載列表
		to_unload_code.push_back(last_lang.code)
		
		# 若 前個備選語言 存在
		if last_fallback_langs != null :
			# 加入 前個備選語言 至 卸載列表
			for each in last_fallback_langs :
				to_unload_code.push_back(each)
	
	# 卸載 字典
	for each in to_unload_code :
		self.I18N.loader.unload_dicts(self.get_language(each))
		
	# 載入 字典
	for each in to_load_code :
		self.I18N.loader.load_dicts_default(self.get_language(each))
	
	# 發送 當 語言改變 事件
	self._on_language_changed.emit()

## 翻譯
func trans (text: String, on_step = null) :
	# 本次 翻譯 任務
	var trans_task = self.I18N.Task.new(self, text)
	
	# 是否完成
	var is_done = false
	
	# 是否存在 階段回乎
	var is_on_step_exist := on_step != null and typeof(on_step) == TYPE_CALLABLE
	
	# 目前 翻譯器 序號
	var trans_idx := 0
	# 前次 翻譯器 序號
	var last_idx := 0
	
	# 最大嘗試
	var max_try := 100
	
	# 若 還沒完成
	while not is_done :
		
		# 取得 翻譯器
		var translator = self._translators[trans_idx]
		
		# 代換
#		var untrans = trans_task.text
		var is_trans = await translator.handle(trans_task)
		
		if is_trans :
			var double_check = true
			var double_check_quota = 10
			while double_check and double_check_quota > 0 : 
				double_check_quota -= 1
				double_check = await translator.handle(trans_task)
			
			
#		print("====\n%s\n===trans to===\n%s\n====" % [untrans, trans_task.text])
		
		# 若有成功翻譯 則 設為最後一個有翻譯的翻譯器
		if is_trans :
			last_idx = trans_idx
		
		# 推進
		trans_idx += 1
		if trans_idx >= self._translators.size() :
			trans_idx = 0
			
		# 若有階段回呼 則 呼叫
		if is_on_step_exist :
			on_step.call(trans_task.text)
			
		# 若 下個翻譯器 與 最後一次有翻譯的翻譯器 一樣
		if trans_idx == last_idx :
			# 完成翻譯
			is_done = true
			
		max_try -= 1
		if max_try <= 0 :
			is_done = true
		
	return trans_task.text
	

## 新增 翻譯器
func add_translator (translator) :
	self._translators.push_back(translator)

## 新增 當 語言 變更
func on_language_changed (listener_or_fn) :
	self._on_language_changed.on(listener_or_fn)

## 移除 當 語言 變更
func off_language_changed (listener_or_tag) :
	self._on_language_changed.off(listener_or_tag)
	

## 新增 當 更新
func on_update (listener_or_fn) :
	return self._on_update.on(listener_or_fn)

## 移除 當 更新
func off_update (listener_or_tag) :
	self._on_update.off(listener_or_tag)


# 字典 ===============

# 設置 鍵:詞
func set_word (key: String, word) :
	var cur_lang = self.get_current_language()
	if cur_lang == null : return null
	if word != null :
		cur_lang.key_to_word[key] = word
	else :
		if cur_lang.key_to_word.has(key) :
			cur_lang.key_to_word.erase(key)

# 取得 詞
func get_word (key: String) :
	var cur_lang = self.get_current_language()
	if cur_lang == null : return null
	if cur_lang.key_to_word.has(key) == false : return null
	return cur_lang.key_to_word[key]

## 設置 鍵:函式
func set_func (key: String, fn) :
	if fn is Callable :
		self._key_to_func[key] = fn
	elif fn == null :
		if self._key_to_func.has(key) :
			self._key_to_func.erase(key)

## 取得 函式
func get_func (key: String) :
	if self._key_to_func.has(key) == false :
		return null
	return self._key_to_func[key]


# Private ====================
