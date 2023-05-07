# desc ==========

## 索引 I18N 在地化文字
##
## 依照不同的語言, 透過多個翻譯器來代換文本內其中不同形式的關鍵字為目標文字.
## 

# const =========

## 路徑
var PATH : String

## 語言 描述檔 檔名
var LANG_META_FILE_NAME := "_meta.ini"

# sub_index =====

## 在地化 實體
var Inst
## 翻譯器
var Trans
## 任務
var Task
## 語言資料
var Lang
## 讀取器
var Loader

# inst ==========

## 讀取器
var loader

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("I18N")
	
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("i18n_inst.gd"))
	self.Trans = G.v.Uzil.load_script(self.PATH.path_join("i18n_translator.gd"))
	self.Task = G.v.Uzil.load_script(self.PATH.path_join("i18n_task.gd"))
	self.Lang = G.v.Uzil.load_script(self.PATH.path_join("i18n_lang.gd"))
	self.Loader = G.v.Uzil.load_script(self.PATH.path_join("i18n_loader.gd"))
	
	self.loader = self.Loader.new()
	
	return self

## 初始化
func init (_parent_index) :
	return self

## 建立 實體
func create_inst () :
	var inst = self.Inst.new()
	
	# 詞 翻譯器
	var trans_word = self.Trans.new(G.v.Uzil.load_script(self.PATH.path_join("handlers/i18n_handler_word.gd")).new())
	inst.add_translator(trans_word)
	
	# 變數 翻譯器
	var trans_vars = self.Trans.new(G.v.Uzil.load_script(self.PATH.path_join("handlers/i18n_handler_vars.gd")).new())
	inst.add_translator(trans_vars)
	
	# 檔案 翻譯器
	var trans_file = self.Trans.new(G.v.Uzil.load_script(self.PATH.path_join("handlers/i18n_handler_file.gd")).new())
	inst.add_translator(trans_file)
	
	# 函式 翻譯器
	var trans_func = self.Trans.new(G.v.Uzil.load_script(self.PATH.path_join("handlers/i18n_handler_func.gd")).new())
	inst.add_translator(trans_func)
	
	return inst
