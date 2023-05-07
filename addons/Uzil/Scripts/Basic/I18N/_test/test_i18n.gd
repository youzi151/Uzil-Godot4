extends Uzil_Test_Base

# Variable ===================

var test_num := 0

var _vars = null

# Extends ====================
func test_unactive():
	var childs = self.get_children()
	for child in childs :
		if "visible" in child :
			child.visible = false
	
func test_ready():

	
	# 讀取 所有語言資料
	G.v.Uzil.i18n.load_languages(G.v.Uzil.Basic.I18N.PATH.path_join("_test/langs"))
	
	# 切換語言
	G.v.Uzil.i18n.change_language("tchinese")
	
	# 準備要翻譯的
	var to_trans = ""
	
	# 詞 ========
	to_trans += "<\uFFFF#test#\uFFFF> : <#test#> <#to_test#> <#test_fallback#> num[<#num#>] dict[<#dict#>] %s\n" # 同時檢查 %s 是否會造成問題
	
	# 變數 ======
	G.v.Uzil.vars.inst("test").set_var("test", "VARS.TEST")
	G.v.Uzil.vars.inst().set_var("test", "<$test:test$>")
	G.v.Uzil.vars.inst().set_var("num", 99.87)
	G.v.Uzil.vars.inst().set_var("dict", {"arr":[1, 2, 3]})
	to_trans += "<\uFFFF$test$\uFFFF> : <$test:test$> & <$test$> num[<$num$>] dict[<$dict$>]\n"
	
	# 檔案 ======
	to_trans += "<\uFFFF@test@\uFFFF> : <@%s@> & <@%s@> num[<@%s@>] dict[<@%s@>]\n" % [
		G.v.Uzil.Basic.I18N.PATH.path_join("_test/files/%LANG%/test_with_sec.txt|sec:key"),
		G.v.Uzil.Basic.I18N.PATH.path_join("_test/files/%LANG%/test.txt|key"),
		G.v.Uzil.Basic.I18N.PATH.path_join("_test/files/%LANG%/test.txt|num"),
		G.v.Uzil.Basic.I18N.PATH.path_join("_test/files/%LANG%/test.txt|dict"),
	]
	
	# 函式 ======
	G.v.Uzil.i18n.add_func("test", func () :
		self.test_num += 1
		return "FUNC(%s)" % self.test_num	
	)
	G.v.Uzil.i18n.add_func("to_test", func () :
		return "<^test^>"
	)
	G.v.Uzil.i18n.add_func("num", func () :
		return 99.87
	)
	G.v.Uzil.i18n.add_func("dict", func () :
		return {"arr":[1, 2, 3]}
	)
	to_trans += "<\uFFFF^test^\uFFFF> : <^test^> <^to_test^> <^test^> num[<^num^>] dict[<^dict^>]"

	# 印出 翻譯	
	print(to_trans)
	print("======== trans to ============")
	print(G.v.Uzil.i18n.trans(to_trans))
	G.v.Uzil.i18n.update()
	
	self._vars = G.v.Uzil.vars.inst()
	self._vars.set_var("test_label_time", 0)
	self._vars.set_var("test_label_time_str", 0)

func test_process(_delta):
	self._vars = G.v.Uzil.vars.inst()
	
	var time = self._vars.get_var("test_label_time")
	time = time + _delta
	self._vars.set_var("test_label_time", time)
	
	self._vars.set_var("test_label_time_str", floor(time))
	
	G.v.Uzil.i18n.update()

# Public =====================

