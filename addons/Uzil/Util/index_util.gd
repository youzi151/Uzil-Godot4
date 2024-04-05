
# desc ==========

## Util 公用工具
## 
## 1. 最基礎的公用工具, 不能依賴Util以外的其他模塊.[br]
## 2. 主要以直接可呼叫使用為目標, 減少外部使用還需先new建立物件的狀況.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 子索引
var sub_indexes := []

## 隨機
var RNG


# class =========

## 圖
var Graph

## 曲線
var Curves

# inst ==========

## 數學
var math
## 非同步
var async
## 腳本相關
var gdscript
## 輸入
var input
## 字典
var dict
## 陣列
var array
## 字串
var string
## 獨特ID
var uniq_id
## HTTP
var http
## 截圖
var screenshot

# other =========

var _class := {}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Util")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Util",
		func () :
			
			# inner class
			self._class._Math = Uzil.load_script(self.PATH.path_join("math.gd"))
			self._class._Async = Uzil.load_script(self.PATH.path_join("async.gd"))
			self._class._GDScript = Uzil.load_script(self.PATH.path_join("gdscript.gd"))
			self._class._Input = Uzil.load_script(self.PATH.path_join("Input/input.gd"))
			self._class._Keycode = Uzil.load_script(self.PATH.path_join("Input/keycode.gd"))
			self._class._Dictionary = Uzil.load_script(self.PATH.path_join("dictionary.gd"))
			self._class._Array = Uzil.load_script(self.PATH.path_join("array.gd"))
			self._class._String = Uzil.load_script(self.PATH.path_join("string.gd"))
			self._class._UniqID = Uzil.load_script(self.PATH.path_join("uniq_id.gd"))
			self._class._Http = Uzil.load_script(self.PATH.path_join("http.gd"))
			self._class._Screenshot = Uzil.load_script(self.PATH.path_join("screenshot.gd"))
			
			# class
			self.Graph = Uzil.load_script(self.PATH.path_join("Graph/graph.gd"))
			self.Curves = Uzil.load_script(self.PATH.path_join("curves.gd"))

			self.init(_parent_index)
			return self
	)
	
	# sub index
	self.RNG = Uzil.load_script(self.PATH.path_join("RNG/index_rng.gd")).new()
	self.sub_indexes.push_back("RNG")
	
	# 建立索引
	for each in self.sub_indexes :
		self[each].index(Uzil, self)
	
	return self

## 初始化
func init (__parent_index) :
	
	self.math = self._class._Math.new()
	self.async = self._class._Async.new()
	self.gdscript = self._class._GDScript.new()
	self.string = self._class._String.new()
	self.dict = self._class._Dictionary.new()
	self.array = self._class._Array.new()
	self.uniq_id = self._class._UniqID.new()
	self.http = self._class._Http.new()
	self.screenshot = self._class._Screenshot.new()
	
	var keycode = self._class._Keycode.new()
	self.input = self._class._Input.new().init(keycode)
	
	return self
