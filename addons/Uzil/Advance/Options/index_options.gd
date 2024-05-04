# desc ==========

## 索引 Options 設定
##
## 提供設置遊戲各種選項
## 

class OptsKit :
	var game
	var display
	var audio
	var _path : String = ""
	func _init (path: String) :
		self._path = path
	func load_config () :
		self.game.load_config(self._path)
		self.display.load_config(self._path)
		self.display.apply()
		self.display.apply.call_deferred()
		self.audio.load_config(self._path)

# const =========

## 路徑
var PATH : String

## 設定檔 路徑
var CONFIG_FILE_PATH := "./pref.cfg"

# sub_index =====

## 遊戲
var Game
## 顯示
var Display
## 音量
var Audio

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Options")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Advance.Options",
		func():
			self.Game = Uzil.load_script(self.PATH.path_join("options_game.gd"))
			self.Display = Uzil.load_script(self.PATH.path_join("options_display.gd"))
			self.Audio = Uzil.load_script(self.PATH.path_join("options_audio.gd"))
			return self,
		{
			"alias" : ["Options"]
		}
	)
	
	# 綁定 工具組
	UREQ.bind("Uzil", "options",
		func():
			return self.create_kit(),
		{
			"requires" : ["Advance.Options"],
		}
	)

## 建立 工具組
func create_kit () :
	
	var kit := OptsKit.new(self.CONFIG_FILE_PATH)
	var to_load_configs := []
	
	kit.game = self.Game.new()
	kit.display = self.Display.new()
	kit.audio = self.Audio.new()
	
	return kit
	
