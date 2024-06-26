extends Node

## Audio.Mgr 音效 管理
##
## 管理 音效層級, 音效物件...等. 並提供操作.
## 

# Variable ===================

## 層級
var _id_to_layer := {}

## 物件
var _id_to_obj := {}

## 預設層級
var default_layers := []

## 設置表
var key_to_preset := {}

var _container_layer : Node = null
var _container_obj : Node = null

# GDScript ===================

func _init (_dont_set_in_scene) :
	self._container_layer = Node.new()
	self._container_layer.name = "Layers"
	self.add_child(self._container_layer)
	
	self._container_obj = Node.new()
	self._container_obj.name = "Objs"
	self.add_child(self._container_obj)
	

# Extends ====================

# Public =====================

## 設置 配置
func set_preset (key: String, data) :
	if data == null :
		if self.key_to_preset.has(key) :
			self.key_to_preset.erase(key)
	else :
		match typeof(data) :
			TYPE_STRING :
				self.key_to_preset[key] = {
					"file" : data
				}
			TYPE_DICTIONARY :
				self.key_to_preset[key] = data

## 取得 配置
func get_preset (key: String) :
	if not self.key_to_preset.has(key) : return null
	return self.key_to_preset[key]

# 物件 =============

## 準備
func prepare (audio_id: String, path_or_key: String, data = null) :
	
	var audio_obj = self.get_audio(audio_id)
	
	var src_path : String = path_or_key
	var preset = self.get_preset(path_or_key)
	if preset != null and preset.has("file") :
		src_path = preset["file"]
	
	if audio_obj != null and audio_obj.src == src_path:
		audio_obj.set_data(data)
	else :
		audio_obj = await self.request(audio_id, src_path, data)
	
	return audio_obj

## 請求
func request (audio_id: String, path_or_key: String, data := {}) :
	
	var id = self._handle_id_in_request(audio_id)
	
	var audio_obj = await self._create_obj(id, path_or_key, data)
	
	if audio_obj == null : return null
	
	audio_obj.on_destroy.on(func(_ctrlr):
		var _id = _ctrlr.data.get_id()
		if self._id_to_obj.has(_id) :
			self._id_to_obj.erase(_id)
	)
	
	self._id_to_obj[id] = audio_obj
	
	return audio_obj

## 釋放
func release (audio_id_or_obj) :
	
	if typeof(audio_id_or_obj) == TYPE_STRING :
		var audio_obj = self.get_audio(audio_id_or_obj)
		if audio_obj != null :
			audio_obj.queue_free()
			self._id_to_obj.erase(audio_id_or_obj)
		
	else :
		for key in self._id_to_obj.keys() :
			if self._id_to_obj[key] == audio_id_or_obj :
				self._id_to_obj.erase(key)
				audio_id_or_obj.queue_free()
				break

# 操作 =============

## 取得
func get_audio (audio_id: String) :
	if not self.is_exist(audio_id) : return null
	return self._id_to_obj[audio_id]

## 是否存在
func is_exist (audio_id: String) -> bool :
	return self._id_to_obj.has(audio_id)

## 是否播放中
func is_playing (audio_id: String) :
	if not self.is_exist(audio_id) : return null
	var audio_obj = self.get_audio(audio_id)
	return audio_obj.is_playing()

## 設置
func set_data (audio_id: String, data) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	audio_obj.set_data(data)

## 設置 音量
func set_volume (audio_id: String, volume: float) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	audio_obj.set_volume(volume)

## 播放 (匿名, 直接指定資源)
func emit (path_or_key: String, data := {}) :
	var audio_obj = await self.request("", path_or_key, data)
	audio_obj.is_release_on_end = true
	if audio_obj :
		audio_obj.play()
		
	return audio_obj

## 播放
func play (audio_id: String, data = null) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	
	if data :
		audio_obj.set_data(data)
		
	audio_obj.play()

## 停止
func stop (audio_id: String, is_force := false) :
	if not self.is_exist(audio_id) : 
		G.print("%s not exist" % audio_id)
		return
	var audio_obj = self.get_audio(audio_id)
	
	audio_obj.stop(is_force)

## 停止 所有
func stop_all () :
	for each in self._id_to_obj.values() :
		each.stop()

## 復原
func resume (audio_id: String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return
	audio_obj.resume()

## 復原 所有
func resume_all () :
	pass

## 暫停
func pause (audio_id: String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return
	audio_obj.pause()

## 暫停 所有
func pause_all () :
	pass

# 層級 =============

## 新增 層級
func set_layer (layer_id: String, data = null) :
	var audio_layer = self.get_layer(layer_id)
	
	if audio_layer == null :
		audio_layer = UREQ.acc(&"Uzil:Advance.Audio").Layer.new(self)
		self._id_to_layer[layer_id] = audio_layer
	
	if data != null :
		audio_layer.set_data(data)
	
	return audio_layer

## 移除 層級
func del_layer (layer_id: String) :
	self._id_to_layer.erase(layer_id)

## 取得 層級
func get_layer (layer_id: String) :
	if not self._id_to_layer.has(layer_id) : return null
	return self._id_to_layer[layer_id]

## 將 層級 加入 至 物件
func join_layer (audio_id: String, layer_id: String) : 
	
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return false
	var audio_layer = self.get_layer(layer_id)
	if audio_layer == null : return false
	
	audio_layer.add_audio(audio_id)
	audio_obj.add_layer(layer_id)
	return true

## 將 層級 移除 從 物件
func leave_layer (audio_id: String, layer_id: String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj != null : audio_obj.del_layer(layer_id)
	
	var audio_layer = self.get_layer(layer_id)
	if audio_layer != null : audio_layer.del_audio(audio_id)

# Bus =============

## 請求 AudioBus
func request_bus (bus_id: String) :
	var bus_idx := self.get_bus_idx(bus_id)
	if bus_idx != -1 :
		return bus_idx
		
	bus_idx = AudioServer.bus_count
	AudioServer.add_bus(bus_idx)
	AudioServer.set_bus_name(bus_idx, bus_id)
	return bus_idx

## 取得 AudioBus 序號
func get_bus_idx (bus_id: String) -> int :
	var bus_idx := AudioServer.get_bus_index(bus_id)
	if bus_idx == -1 :
		if bus_id.is_valid_int() :
			bus_idx = bus_id.to_int()
	return bus_idx

func set_bus_volume (bus_id: String, volume_linear: float) :
	var bus_idx = self.request_bus(bus_id)
	var volume_db = UREQ.acc(&"Uzil:Util").math.percent_to_db(volume_linear)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

# Private ====================

## 建立物件
func _create_obj (id: String, path_or_key: String, data := {}) :
	var Audio = UREQ.acc(&"Uzil:Advance.Audio")
	var res_mgr = UREQ.acc(&"Uzil:res_mgr")
	
	if not data.is_empty() :
		data = data.duplicate()
	
	var src_path : String = path_or_key
	
	var preset = self.get_preset(path_or_key)
	if preset != null : 
		
		if preset.has("file") :
			src_path = preset["file"]
		
		if data != null :
			data.merge(preset, false)
	
	var res_info = await res_mgr.hold(src_path)
	if res_info == null : return
	if res_info.res == null : return
	
	var audio_stream : AudioStream = res_info.res
	
	var space_type = null
	if data != null :
		if data.has("space") :
			space_type = data["space"]
			
	var audio_player
	match space_type :
		Audio.AudioSpaceType.TWO_D :
			audio_player = AudioStreamPlayer2D.new()
		Audio.AudioSpaceType.THREE_D :
			audio_player = AudioStreamPlayer3D.new()
		_ :
			audio_player = AudioStreamPlayer.new()
	
	audio_player.stream = audio_stream
	
	var audio_obj = Audio.Obj.new(self, id, audio_player)
	(audio_obj as Node).add_child(audio_player)
	
	if data != null :
		audio_obj.set_data(data)
	
	self._container_obj.add_child(audio_obj)
	
	return audio_obj


## 處理 ID 
func _handle_id_in_request (id: String) -> String :
	# 若為空 則 取匿名ID
	if id.is_empty() :
		id = "_anonymous_"
		id = UREQ.acc(&"Uzil:Util").uniq_id.fix(id, func(newID) :
			return self._id_to_obj.has(newID) == false
		)
		
	# 若 已存在 則 釋放 之前的
	if self._id_to_obj.has(id) :
		self.release(id)
		
	return id
