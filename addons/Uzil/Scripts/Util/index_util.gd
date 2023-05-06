
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

# inst ==========

## 數學
var math
## 非同步
var async
## 腳本相關
var gdscript
## 輸入
var input
## 字串
var string
## 獨特ID
var uniq_id

# other =========

var _class = {}

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Util")
	
	# sub index
	self.RNG = G.v.Uzil.load_script(self.PATH.path_join("RNG/index_rng.gd")).new()
	self.sub_indexes.push_back(self.RNG)
	
	# inner class
	self._class._Math = G.v.Uzil.load_script(self.PATH.path_join("math.gd"))
	self._class._Async = G.v.Uzil.load_script(self.PATH.path_join("async.gd"))
	self._class._GDScript = G.v.Uzil.load_script(self.PATH.path_join("gdscript.gd"))
	self._class._Input = G.v.Uzil.load_script(self.PATH.path_join("Input/input.gd"))
	self._class._Keycode = G.v.Uzil.load_script(self.PATH.path_join("Input/keycode.gd"))
	self._class._String = G.v.Uzil.load_script(self.PATH.path_join("string.gd"))
	self._class._UniqID = G.v.Uzil.load_script(self.PATH.path_join("uniq_id.gd"))
	
	# 建立索引
	for each in self.sub_indexes :
		each.index(self)
	
	return self

## 初始化
func init (__parent_index) :
	
	self.math = self._class._Math.new()
	self.async = self._class._Async.new()
	self.gdscript = self._class._GDScript.new()
	self.string = self._class._String.new()
	self.uniq_id = self._class._UniqID.new()
	
	var keycode = self._class._Keycode.new()
	self.input = self._class._Input.new().init(keycode)
	
	# 初始化
	for each in self.sub_indexes :
		each.init(self)
	
	return self
