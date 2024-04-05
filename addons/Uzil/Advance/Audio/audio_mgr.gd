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

## 路徑表
var key_to_path := {}

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
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass

# Extends ====================

# Public =====================

## 讀取 路徑表
func load_path_table (full_path : String):
	var config_file = ConfigFile.new()
	var err = config_file.load(full_path)
	if err == OK :
		var section
		var sections = config_file.get_sections()
		if sections.size() == 0 :
			section = ""
		else :
			section = sections[0]
			
		var keys = config_file.get_section_keys(section)
		for key in keys :
			self.key_to_path[key] = config_file.get_value(section, key, null)
		

## 新增 鍵:路徑
func add_key_to_path (key : String, full_path : String) :
	self.key_to_path[key] = full_path

## 移除 鍵:路徑
func del_key_to_path (key : String) :
	if not self.key_to_path.has(key) : return
	self.key_to_path.erase(key)


# 物件 =============

## 準備
func prepare (audio_id : String, path_or_key : String, data = null) :
	
	var audio_obj = self.get_audio(audio_id)
	
	var src_path = self._get_res_path(path_or_key)
	
	if audio_obj != null and audio_obj.src == src_path:
		audio_obj.set_data(data)
	else :
		audio_obj = await self.request(audio_id, src_path, data)
	
	return audio_obj

## 請求
func request (audio_id : String, path_or_key : String, data = null) :
	
	var id = self._handle_id_in_request(audio_id)
	
	var audio_obj = await self._create_obj(id, path_or_key, data)
	
	self._id_to_obj[id] = audio_obj
	
	if audio_obj == null : return null
	
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

# 操作 =============

## 取得
func get_audio (audio_id : String) :
	if not self.is_exist(audio_id) : return null
	return self._id_to_obj[audio_id]

## 是否存在
func is_exist (audio_id : String) -> bool :
	return self._id_to_obj.has(audio_id)

## 是否播放中
func is_playing (audio_id : String) :
	if not self.is_exist(audio_id) : return null
	var audio_obj = self.get_audio(audio_id)
	return audio_obj.is_playing()

## 設置
func set_data (audio_id : String, data) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	audio_obj.set_data(data)

## 設置 音量
func set_volume (audio_id : String, volume : float) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	audio_obj.set_volume(volume)

## 播放 (匿名, 直接指定資源)
func emit (path_or_key : String, data = null) :
	var audio_obj = await self.request("", path_or_key, data)
	if audio_obj :
		audio_obj.play()
		
	return audio_obj

## 播放
func play (audio_id : String, data = null) :
	if not self.is_exist(audio_id) : return
	var audio_obj = self.get_audio(audio_id)
	
	if data :
		audio_obj.set_data(data)
		
	audio_obj.play()

## 停止
func stop (audio_id : String, is_force := false) :
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
func resume (audio_id : String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return
	audio_obj.resume()

## 復原 所有
func resume_all () :
	pass

## 暫停
func pause (audio_id : String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return
	audio_obj.pause()

## 暫停 所有
func pause_all () :
	pass

# 層級 =============

## 新增 層級
func set_layer (layer_id : String, data = null) :
	var audio_layer = self.get_layer(layer_id)
	
	if audio_layer == null :
		audio_layer = UREQ.acc("Uzil", "Advance.Audio").Layer.new(self)
		self._id_to_layer[layer_id] = audio_layer
	
	if data != null :
		audio_layer.set_data(data)
	
	return audio_layer

## 移除 層級
func del_layer (layer_id : String) :
	self._id_to_layer.erase(layer_id)

## 取得 層級
func get_layer (layer_id : String) :
	if not self._id_to_layer.has(layer_id) : return null
	return self._id_to_layer[layer_id]

## 將 層級 加入 至 物件
func join_layer (audio_id : String, layer_id : String) : 
	
	var audio_obj = self.get_audio(audio_id)
	if audio_obj == null : return false
	var audio_layer = self.get_layer(layer_id)
	if audio_layer == null : return false
	
	audio_layer.add_audio(audio_id)
	audio_obj.add_layer(layer_id)
	return true

## 將 層級 移除 從 物件
func leave_layer (audio_id : String, layer_id : String) :
	var audio_obj = self.get_audio(audio_id)
	if audio_obj != null : audio_obj.del_layer(layer_id)
	
	var audio_layer = self.get_layer(layer_id)
	if audio_layer != null : audio_layer.del_audio(audio_id)

# Bus =============

## 請求 AudioBus
func request_bus (bus_id) :
	var bus_idx := self.get_bus_idx(bus_id)
	if bus_idx != -1 :
		return bus_idx
		
	bus_idx = AudioServer.bus_count
	AudioServer.add_bus(bus_idx)
	AudioServer.set_bus_name(bus_idx, bus_id)
	return bus_idx

## 取得 AudioBus 序號
func get_bus_idx (bus_id) -> int :
	var bus_idx := AudioServer.get_bus_index(bus_id)
	if bus_idx == -1 :
		if typeof(bus_id) != TYPE_INT :
			return -1
			
		if bus_id < 0 or bus_id > AudioServer.bus_count :
			return -1
		
		bus_idx = bus_id
		
	return bus_idx

func set_bus_volume (bus_id, volume_linear : float) :
	var bus_idx = self.request_bus(bus_id)
	var volume_db = UREQ.acc("Uzil", "Util").math.percent_to_db(volume_linear)
	AudioServer.set_bus_volume_db(bus_idx, volume_db)

# Private ====================

## 建立物件
func _create_obj (id, path_or_key, data = null) :
	var Audio = UREQ.acc("Uzil", "Audio")
	var res_mgr = UREQ.acc("Uzil", "res_mgr")
	
	var src_path := self._get_res_path(path_or_key)
	
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

## 取得 資源路徑 (以路徑或關鍵字)
func _get_res_path (path_or_key) -> String :
	var path = path_or_key
	
	if self.key_to_path.has(path_or_key) :
		path = self.key_to_path[path_or_key]
		
#	var vars_inst = UREQ.acc("Uzil", "vars").inst("_audio")
#	if vars_inst.has_key(path_or_key) :
#		var new_path = vars_inst.get_var(path_or_key)
#		if typeof(new_path) == TYPE_STRING :
#			path = new_path
	return path
	
## 處理 ID 
func _handle_id_in_request (id : String) -> String :
	# 若為空 則 取匿名ID
	if id.is_empty() :
		id = "_anonymous_"
		id = UREQ.acc("Uzil", "Util").uniq_id.fix(id, func (newID) :
			return self._id_to_obj.has(newID) == false
		)
		
	# 若 已存在 則 釋放 之前的
	if self._id_to_obj.has(id) :
		self.release(id)
		
	return id
