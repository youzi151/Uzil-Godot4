@tool
extends Node

## 來源模式
enum SrcMode {
	## ID
	ID, 
	## 配置
	PRESET,
}

# Variable ===================

## 目標按鈕
@export
var button : BaseButton = null :
	set (value) :
		var last : BaseButton = button
		button = value
		
		if Engine.is_editor_hint() : return
		
		if last != null :
			if last.pressed.is_connected(self._on_pressed) :
				last.pressed.disconnect(self._on_pressed)
				
		if button != null :
			if not button.pressed.is_connected(self._on_pressed) :
				button.pressed.connect(self._on_pressed)

## 來源模式
@export
var src_mode : SrcMode = SrcMode.ID :
	set (value) :
		src_mode = value
		self.notify_property_list_changed()

## [來源模式:ID] 音效物件ID
@export
var audio_id : String = ""

## [來源模式:PRESET] 音效配置檔Key
@export
var preset_key : String = ""

# GDScript ===================

func _validate_property (property : Dictionary) -> void :
	match property.name : 
		"audio_id" :
			match self.src_mode : 
				SrcMode.ID :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		"preset_key" :
			match self.src_mode : 
				SrcMode.PRESET :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR

func _ready () :
	if Engine.is_editor_hint() : return
	
	if self.button == null :
		var slf = self
		if slf is BaseButton :
			self.button = slf

func _exit_tree () :
	if Engine.is_editor_hint() : return
	
	# 取得 自身 對應 音效物件
	var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
	var id : String = self._get_preset_audio_id()
	var audio = audio_mgr.get_audio(id)
	# 若 不存在 則 返回
	if audio == null : return
	
	# 若 播放中
	if audio.is_playing() :
		# 標示 為 播完後釋放
		audio.is_release_on_end = true
	# 若 非播放中
	else :
		# 立即釋放
		audio_mgr.release(self._get_preset_audio_id())

## 當 點擊
func _on_pressed () :
	match self.src_mode :
		SrcMode.ID :
			if self.audio_id.is_empty() : return
			
			# 播放 指定ID 的 音效物件
			var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
			audio_mgr.play(self.audio_id)
			
		SrcMode.PRESET :
			if self.preset_key.is_empty() : return
			
			# 試取得 配置對應ID 的 音效物件
			var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
			var _id : String = self._get_preset_audio_id()
			var audio = audio_mgr.get_audio(_id)
			# 若 不存在 則 請求建立
			if audio == null :
				audio = await audio_mgr.request(_id, self.preset_key)
			# 播放
			audio.play()

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

## 取得 配置用 對應自身的音效物件ID
func _get_preset_audio_id () :
	return str("_btn_audio_play.%s" % self.get_instance_id())

