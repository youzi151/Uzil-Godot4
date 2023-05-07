extends Node

## Audio.Obj 音效 物件
##
## 持有引擎實際播放音效的物件, 並額外管理音量, 播放模式...等功能.
## 

# Variable ===================

## 所屬管理器
var mgr = null

## 層級
var _id := "_default"

## 路徑 或 關鍵字
var path_or_key : String

## 音效播放
var audio_player = null

## 是否撥放完後 即 銷毀
@export var is_release_on_end := true

## 是否循環
@export var is_loop := false

## 音量
var target_volume := 1.0
var _target_volume := 1.0
var _target_volume_db := 0.0

## 音量漸變速度 (秒)
var fade_speed_volume_sec := -1.0

## 所屬群組
var _layers : Array[String] = []

## 是否呼叫停止
var _is_call_stop := false

## 是否因為時間停止而暫停
var _is_pause_by_timing_pause := false

## 當 循環 事件
var on_loop = null

## 當 播放結束 事件
var on_end = null

## 當 銷毀 事件
var on_destroy = null

# GDScript ===================

func _init (_mgr, _audio_player) :
	self.mgr = _mgr
	
	self.on_loop = G.v.Uzil.Core.Evt.Inst.new()
	self.on_end = G.v.Uzil.Core.Evt.Inst.new()
	self.on_destroy = G.v.Uzil.Core.Evt.Inst.new()
	
	self.audio_player = _audio_player
	self.audio_player.connect("finished", self._signal_finished)

func _process (_dt) :
	
	var is_timing = G.v.Uzil.times.inst().is_timing()
	var _is_playing = self.is_playing()
	
	if not is_timing and _is_playing :
		self._is_pause_by_timing_pause = true
		self.pause()
		return
		
	elif is_timing and not _is_playing and self._is_pause_by_timing_pause :
		self._is_pause_by_timing_pause = false
		self.resume()
		
	
	if self.audio_player == null : return
	
	# 檢查 並 更新 目標音量
	var target_volume_layered = self._get_layered_volume()
	if target_volume_layered != self._target_volume :
		self._target_volume = target_volume_layered
		self._target_volume_db = G.v.Uzil.Util.math.percent_to_db(self._target_volume)
	
	# 漸變目標音量
	if self.audio_player.volume_db != self._target_volume_db :
		var current_volume : float = G.v.Uzil.Util.math.db_to_percent(self.audio_player.volume_db)
		if self.fade_speed_volume_sec < 0 :
			current_volume = self._target_volume
		else :
			current_volume = move_toward(current_volume, self._target_volume, self.fade_speed_volume_sec * _dt)
		self.audio_player.volume_db = G.v.Uzil.Util.math.percent_to_db(current_volume)
		

func _signal_finished () :
	
	var is_stream_loop = false
	if self.audio_player.stream :
		is_stream_loop = (self.audio_player.stream as AudioStreamOggVorbis).loop
	if self.is_loop and not is_stream_loop :
		
		# 呼叫 循環事件
		self.on_loop.emit()
		
		self.play()
	
	if not self.is_loop :
		# 呼叫 停止事件
		self.on_end.emit()

# Extends ====================

# Public =====================

## 是否播放中
func is_playing () -> bool :
	return self.audio_player.playing

## 播放
func play () :
	self.audio_player.play()
	self._is_call_stop = false
	self.update_layered()

## 停止
func stop (is_force := true) :
	
	if self.audio_player == null : return
	
	# 若 非強制 且 是循環模式
	if not is_force and self.is_loop :
		# 註記 呼叫停止
		self._is_call_stop = true
	else :
		# 停止播放
		self.audio_player.stop()

## 暫停
func pause () :
	self.audio_player.stream_paused = true

## 恢復
func resume () :
	self.audio_player.stream_paused = false

## 取得 時間
func get_time () -> float :
	return self.audio_player.get_playback_position()

## 設置 資料
func set_data (data : Dictionary) :
	if data.has("time") :
		self.set_time(data["time"])
	
	if data.has("bus") :
		self.set_bus(data["bus"])
	elif data.has("mixer") :
		self.set_bus(data["mixer"])
	
	if data.has("layers") :
		self.add_layers(data["layers"])
	
	if data.has("is_playing") :
		var _is_playing = data["is_playing"]
		if _is_playing and not self.is_playing() :
			self.play()
		elif not _is_playing and self.is_playing() :
			self.pause()

## 設置 時間
func set_time (time : float) :
	self.audio_player.seek(time)

## 設置 音效bus
func set_bus (bus : String) -> bool :
	self.audio_player.bus = bus
	self.mgr.request_bus(bus)
	return self.audio_player.bus == bus

## 加入 層級
func add_layer (layer_id : String) :
	if self._layers.has(layer_id) : return
	self._layers.push_back(layer_id)
	
	# 保證互相設置
	self.mgr.set_layer(self._id, layer_id)
	
	self.update_layered()

## 加入 層級
func add_layers (layer_id_list : Array) :
	for layer_id in layer_id_list :
		self.add_layer(layer_id)

## 移除 層級
func del_layer (layer_id : String) :
	if self._layers.has(layer_id) : return
	self._layers.push_back(layer_id)
	
	# 保證互相移除
	self.mgr.unset_layer(self.id, layer_id)

## 更新 音效物件
func update_layered () :
	
	# 重新排序
	self._sort_layers()
	
	# 取得 層級覆蓋後的 是否播放中
	var _is_playing : bool = not self._get_layered_is_pause()
	# 以此進行 恢復 或 暫停
	if self.is_playing() != _is_playing :
		if _is_playing :
			self.resume()
		else :
			self.pause()

# Private ====================

## 排序層級
func _sort_layers () :
	self._layers.sort_custom(func(a, b):
		var a_layer = self.mgr.get_layer(a)
		var b_layer = self.mgr.get_layer(b)
		return a_layer.priority > b_layer.priority
	)

## 取得 層級覆蓋後的 音量
func _get_layered_volume () -> float :
	# 若沒有層級 則 返回 自身目標音量
	if self._layers.size() == 0 : return self.target_volume
	
	# 預設 音量 為 自身目標音量
	var layered_volume = self.target_volume
	
	# 各層級
	for each_layer in self._layers :
		
		var layer = self.mgr.get_layer(each_layer)
		
		# 若 音量為負數 則 忽略
		if layer.volume < 0 : continue
		
		# 目標音量 乘上倍率
		layered_volume *= layer.volume
		break
	
	return layered_volume

## 取得 層級覆蓋後的 是否暫停
func _get_layered_is_pause () -> bool :
	# 若沒有層級 則 返回 自己
	if self._layers.size() == 0 : return not self.is_playing()
	
	# 預設 是否暫停
	var is_pause = not self.is_playing()
	
	# 各層級
	for each_layer in self._layers :
		
		var layer = self.mgr.get_layer(each_layer)
		
		# 若 沒有定義播放狀態 則 忽略
		if layer.play_state == G.v.Uzil.Advance.Audio.LayerPlayState.UNDEFINED : continue
		
		# 覆蓋 是否暫停
		is_pause = layer.play_state == G.v.Uzil.Advance.Audio.LayerPlayState.PAUSE
		
		break
	
	return is_pause

