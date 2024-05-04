
## Audio.Layer 音效 層級
##
## 層級之間, 以優先度影響音效的音量, 播放狀態.
## 

# Variable ===================

## 所屬管理器
var mgr = null

## 層級
var id := "_default"

## 音量
var volume : float = -1

## 播放狀態
var play_state := 0

## 優先度
var priority := 5.0

## 音效物件ID列表
var audio_id_list := []

# GDScript ===================

func _init (_mgr) :
	self.mgr = _mgr
	self.play_state = UREQ.acc("Uzil", "Audio").LayerPlayState.UNDEFINED

# Extends ====================

# Public =====================

# 物件 =============

## 新增 音效物件
func add_audio (audio_id: String) :
	if self.audio_id_list.has(audio_id) : return
	self.audio_id_list.push_back(audio_id)
	
	# 保證互相設置
	self.mgr.join_layer(audio_id, self.id)

## 移除 音效物件
func del_audio (audio_id: String) :
	if not self.audio_id_list.has(audio_id) : return
	self.audio_id_list.erase(audio_id)
	
	# 保證互相移除
	self.mgr.leave_layer(audio_id, self.id)

## 設置 資料
func set_data (data: Dictionary) :
	
	if data.has("volume") :
		self.set_volume(data["volume"], true)
		
	if data.has("priority") :
		self.set_priority(data["priority"], true)
	
	return self

## 設置 音量
func set_volume (_volume: float, is_update_audios := true) :
	self.volume = _volume
	if is_update_audios : self.update_audios()
	return self

## 設置 優先度
func set_priority (_priority: float, is_update_audios := true) :
	self.priority = _priority
	if is_update_audios : self.update_audios()
	return self

## 更新 音效物件
func update_audios () :
	
	for each in self.audio_id_list :
		var audio_obj = self.mgr.get_audio(each)
		if audio_obj == null : continue
		
		# 呼叫 音效物件 自行更新
		audio_obj.update_layered()

# Private ====================

