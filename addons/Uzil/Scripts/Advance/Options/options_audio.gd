
## Options.Audio 選項 音效
##
## 有關音效的選項, 如 音量
##

# Const ======================

## 在 設定檔案 中的 區塊名稱
const CFG_SECTION_NAME := "audio"

const KEY_BUS_PREFIX := "bus_"
const KEY_BUS_VOLUME_SUFFIX := "_volume"

# Variable ===================

var bus_to_volume := {}

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass

# Extends ====================

# Public =====================

## 讀取 設定檔案
func load_config (file_path := "") :
	var Options = UREQ.acc("Uzil", "Advance.Options")
	var user_save = UREQ.acc("Uzil", "user_save")
	
	if file_path == "" :
		file_path = Options.CONFIG_FILE_PATH
	
	var configs = user_save.config.read(file_path, self.CFG_SECTION_NAME, null)
	
	var keys : Array = configs.keys()
	
	for key in keys :
		var each : String = key
		if each.begins_with(self.KEY_BUS_PREFIX) :
			each = each.get_slice(self.KEY_BUS_PREFIX, 1)
			
			if each.ends_with(self.KEY_BUS_VOLUME_SUFFIX) :
				each = each.get_slice(self.KEY_BUS_VOLUME_SUFFIX, 0)
				
				self.set_bus_volume(each, configs[key], false)
			
		

## 設置 混和器 音量
func set_bus_volume (bus_id : String, volume_linear : float, is_save_to_config := true) :
	var audio = UREQ.acc("Uzil", "audio")
	
	audio.set_bus_volume(bus_id, volume_linear)
	
	self.bus_to_volume[bus_id] = volume_linear
	
	if is_save_to_config :
		var key = "%s%s%s" % [self.KEY_BUS_PREFIX, bus_id, self.KEY_BUS_VOLUME_SUFFIX]
		self._write_to_config(key, volume_linear)


# Private ====================

## 寫入 至 設定檔案
func _write_to_config (key, val) :
	var Options = UREQ.acc("Uzil", "Advance.Options")
	var user_save = UREQ.acc("Uzil", "user_save")
	user_save.config.write_val(Options.CONFIG_FILE_PATH, self.CFG_SECTION_NAME, key, val)

