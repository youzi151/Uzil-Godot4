extends Uzil_Test_Base

# Variable ===================

var i18n
var vars

var test_num := 0

var _vars = null

# Extends ====================
func test_unactive():
	var childs = self.get_children()
	for child in childs :
		if "visible" in child :
			child.visible = false
	
func test_ready():
	
	var I18N = UREQ.acc("Uzil", "I18N")
	self.i18n = UREQ.acc("Uzil", "i18n")
	self.vars = UREQ.acc("Uzil", "vars")
	
	# 讀取 所有語言資料
	self.i18n.load_languages(I18N.PATH.path_join("_test/langs"))
	
	# 切換語言
	self.i18n.change_language("tchinese")
	
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
	self.i18n.add_func("test", func () :
		self.test_num += 1
		return "FUNC(%s)" % self.test_num	
	)
	self.i18n.add_func("to_test", func () :
		return "<^test^>"
	)
	self.i18n.add_func("num", func () :
		return 99.87
	)
	self.i18n.add_func("dict", func () :
		return {"arr":[1, 2, 3]}
	)
	to_trans += "<\uFFFF^test^\uFFFF> : <^test^> <^to_test^> <^test^> num[<^num^>] dict[<^dict^>]"

	# 印出 翻譯	
	print(to_trans)
	print("======== trans to ============")
	print(self.i18n.trans(to_trans))
	self.i18n.update()
	
	self._vars = self.vars.inst()
	self._vars.set_var("test_label_time", 0)
	self._vars.set_var("test_label_time_str", 0)

func test_process(_delta):
	self._vars = self.vars.inst()
	
	var time = self._vars.get_var("test_label_time")
	time = time + _delta
	self._vars.set_var("test_label_time", time)
	
	self._vars.set_var("test_label_time_str", floor(time))
	
	self.i18n.update()

# Public =====================

