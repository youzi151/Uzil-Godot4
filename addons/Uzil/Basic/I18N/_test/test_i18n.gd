extends Node

# Variable ===================

## 輸入文字
@export
var input_edit : TextEdit

## 測試 詞 輸入
@export
var test_word_edit : LineEdit

## 測試 變數 輸入
@export
var test_vars_edit : LineEdit

## 偵錯文字
@export
var debug_log : Node = null

## 變數庫管理
var vars

## 變數庫 實例
var vars_inst = null

## 多語系 實例
var i18n_inst = null

## 測試數字計數
var test_num := 0

# GDScript ===================

func _ready () : 
	var I18N = UREQ.acc("Uzil", "I18N")
	
	# 請求 預設實例
	self.i18n_inst = UREQ.acc("Uzil", "i18n")
	# 讀取 所有語言資料
	self.i18n_inst.load_languages(I18N.PATH.path_join("_test/langs"))
	# 切換語言
	self.i18n_inst.change_language("tchinese")
	
	# 設置變數庫變數
	self.vars = UREQ.acc("Uzil", "vars")
	self.vars_inst = self.vars.inst()
	self.vars_inst.set_var("test_label_time", 0)
	self.vars_inst.set_var("test_label_time_str", 0)
	
	self.test_word_edit.text_changed.connect(func (new_text : String) :
		if new_text == null or new_text == "" :
			new_text = "<#label_word#>"
		self.i18n_inst.set_word("label_word", new_text)
		self.i18n_inst.update({
			"specifics" : ["test_word_edit"]
		})
	)
	
	self.test_vars_edit.text_changed.connect(func (new_text : String) :
		if new_text == null or new_text == "" :
			new_text = "<$label_vars$>"
		self.vars_inst.set_var("label_vars", new_text)
		self.i18n_inst.update({
			"specifics" : ["test_vars_edit"]
		})
	)
	
	self.i18n_inst.update()
	
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_i18n")

func _process (_delta) :
	pass
	#var time = self.vars_inst.get_var("test_label_time")
	#time = time + _delta
	#self.vars_inst.set_var("test_label_time", time)
	#
	#self.vars_inst.set_var("test_label_time_str", floor(time))
	#
	#self.i18n_inst.update()

func _exit_tree () :
	G.off_print("test_i18n")
	

# Extends ====================

# Public =====================

func test_normal () :
	var txt = self.input_edit.text
	G.print(self.i18n_inst.trans(txt))

func test_simple () :
	var I18N = UREQ.acc("Uzil", "I18N")
	
	# 準備要翻譯的
	var to_trans = ""
	
	# 詞 ========
	to_trans += "<\uFFFF#test#\uFFFF> : <#test#> <#to_test#> <#test_fallback#> num[<#num#>] dict[<#dict#>] %s\n" # 同時檢查 %s 是否會造成問題
	
	# 變數 ======
	self.vars.inst("test").set_var("test", "VARS.TEST")
	self.vars.inst().set_var("test", "<$test:test$>")
	self.vars.inst().set_var("num", 99.87)
	self.vars.inst().set_var("dict", {"arr":[1, 2, 3]})
	to_trans += "<\uFFFF$test$\uFFFF> : <$test:test$> & <$test$> num[<$num$>] dict[<$dict$>]\n"
	
	# 檔案 ======
	to_trans += "<\uFFFF@test@\uFFFF> : <@%s@> & <@%s@> num[<@%s@>] dict[<@%s@>]\n" % [
		I18N.PATH.path_join("_test/files/%LANG%/test_with_sec.txt|sec:key"),
		I18N.PATH.path_join("_test/files/%LANG%/test.txt|key"),
		I18N.PATH.path_join("_test/files/%LANG%/test.txt|num"),
		I18N.PATH.path_join("_test/files/%LANG%/test.txt|dict"),
	]
	
	# 函式 ======
	self.i18n_inst.set_func("test", func () :
		self.test_num += 1
		return "FUNC(%s)" % self.test_num	
	)
	self.i18n_inst.set_func("to_test", func () :
		return "<^test^>"
	)
	self.i18n_inst.set_func("num", func () :
		return 99.87
	)
	self.i18n_inst.set_func("dict", func () :
		return {"arr":[1, 2, 3]}
	)
	to_trans += "<\uFFFF^test^\uFFFF> : <^test^> <^to_test^> <^test^> num[<^num^>] dict[<^dict^>]"

	# 印出 翻譯	
	G.print(to_trans)
	G.print("======== trans to ============")
	G.print(self.i18n_inst.trans(to_trans))
	self.i18n_inst.update()

