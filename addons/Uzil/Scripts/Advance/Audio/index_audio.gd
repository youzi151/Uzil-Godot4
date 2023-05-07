# desc ==========

## 索引 Audio 音效
##
## 產生與管理音效物件
## 

# const =========

## 路徑
var PATH : String

## 層級播放狀態
const AudioSpaceType := {
	UNDEFINED = 1,
	TWO_D = 2,
	THREE_D = 3,
}

## 層級播放狀態
const LayerPlayState := {
	UNDEFINED = 0,
	PLAY = 1,
	PAUSE = 2,
}

# sub_index =====

## 音效管理
var Mgr
## 物件
var Obj
## 層級
var Layer

# inst ==========

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Audio")
	
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("audio_mgr.gd"))
	self.Obj = G.v.Uzil.load_script(self.PATH.path_join("audio_obj.gd"))
	self.Layer = G.v.Uzil.load_script(self.PATH.path_join("audio_layer.gd"))

## 初始化
func init (_parent_index) :
	
	return self
	
