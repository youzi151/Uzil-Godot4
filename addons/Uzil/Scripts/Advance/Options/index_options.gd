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

# inst ==========

## 遊戲
var game
## 顯示
var display
## 音量
var audio

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Options")
	
	self.Game = G.v.Uzil.load_script(self.PATH.path_join("options_game.gd"))
	self.Display = G.v.Uzil.load_script(self.PATH.path_join("options_display.gd"))
	self.Audio = G.v.Uzil.load_script(self.PATH.path_join("options_audio.gd"))
	

## 初始化
func init (_parent_index) :
	
	var to_load_configs := []
	
	self.game = self.Game.new()
	to_load_configs.push_back(self.game)
	
	self.display = self.Display.new()
	to_load_configs.push_back(self.display)
	
	self.audio = self.Audio.new()
	to_load_configs.push_back(self.audio)
	
	for each in to_load_configs :
		each.load_config(self.CONFIG_FILE_PATH)
	
	return self
	
