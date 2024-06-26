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
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Audio")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Advance.Audio",
		func():
			self.Mgr = Uzil.load_script(self.PATH.path_join("audio_mgr.gd"))
			self.Obj = Uzil.load_script(self.PATH.path_join("audio_obj.gd"))
			self.Layer = Uzil.load_script(self.PATH.path_join("audio_layer.gd"))
			return self,
		{
			"alias" : ["Audio"]
		}
	)
	
	# 綁定 實體管理
	UREQ.bind(&"Uzil", &"audio_mgr", 
		func():
			var target = self.Mgr.new(null)
			target.name = "audio_mgr"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["audio"],
			"requires" : ["Advance.Audio"],
		}
	)
	
