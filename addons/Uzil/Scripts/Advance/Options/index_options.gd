# desc ==========

## 索引 Options 設定
##
## 提供設置遊戲各種選項
## 

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
	UREQ.bind_g("Uzil", "Advance.Options",
		func () :
			self.Game = Uzil.load_script(self.PATH.path_join("options_game.gd"))
			self.Display = Uzil.load_script(self.PATH.path_join("options_display.gd"))
			self.Audio = Uzil.load_script(self.PATH.path_join("options_audio.gd"))
			return self,
		{
			"alias" : ["Options"]
		}
	)
	
	# 綁定 工具組
	UREQ.bind_g("Uzil", "options",
		func () :
			return self.create_kit(),
		{
			"requires" : ["Advance.Options"],
		}
	)

## 建立 工具組
func create_kit () :
	
	var kit := {}
	var to_load_configs := []
	
	kit.game = self.Game.new()
	to_load_configs.push_back(kit.game)
	
	kit.display = self.Display.new()
	to_load_configs.push_back(kit.display)
	
	kit.audio = self.Audio.new()
	to_load_configs.push_back(kit.audio)
	
	for each in to_load_configs :
		each.load_config(self.CONFIG_FILE_PATH)
	
	return kit
	
