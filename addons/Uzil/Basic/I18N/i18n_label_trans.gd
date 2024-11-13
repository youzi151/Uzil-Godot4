extends Node

## i18n label trans 文字UI翻譯
##
## 提供快速設置代換文字到文字UI上.
##

var i18n

# Variable ===================

enum UpdateMode { MANUAL, PROCESS, ON_UPDATE}

## 更新模式
@export var update_mode : UpdateMode = UpdateMode.ON_UPDATE

## 原始文字
@export_multiline var raw_text : String = ""

## 格式參數 字典
@export var format_dict : Dictionary = {}

## 格式參數 陣列
@export var format_array : Array = []

## 更新事件標籤
@export var on_update_tags : Array[String] = []

## 要代換的文字UI
@export var label_nodes : Array[NodePath] = []


## 更新 偵聽者
var on_update_listener = null

# GDScript ===================

func _init () :
	var Uzil = UREQ.acc(&"Uzil:Uzil")
	
	Uzil.once_ready(func():
		
		self._get_i18n()
	
		# 註冊 當 多語系更新時 更新
		self.register_on_update()
		
		# 首次更新
		self.update()
	)

func _exit_tree () :
	# 註銷 當 多語系更新時 更新
	if self.on_update_listener != null :
		self._get_i18n().off_update(self.on_update_listener)

func _process (_dt: float) :
	if self.update_mode == UpdateMode.PROCESS :
		self.update()

# Extends ====================

# Public =====================

## 清空
func clear () :
	self.raw_text = ""
	self.format_array.clear()
	self.format_dict.clear()

## 設置 原始文字
func set_raw (_raw_text: String, _is_update: bool = true) :
	self.raw_text = _raw_text
	if _is_update : self.update()

## 設置 格式化
func set_format (format, _is_update: bool = true) :
	match typeof(format) :
		TYPE_DICTIONARY :
			self.format_dict = format
		TYPE_ARRAY :
			self.format_array = format
		TYPE_NIL :
			pass
		_ :
			self.format_array = [str(format)]
	if _is_update : self.update()

## 更新
func update () :
	var translated : String = self._get_i18n().trans(self.raw_text)
	if self.format_dict.size() > 0 :
		translated = translated.format(self.format_dict)
	if self.format_array.size() > 0 :
		translated = translated % self.format_array
	
	var slf = self
	if slf is RichTextLabel or slf is Label :
		self._set_text_to(slf, translated)
	
	for each in self.label_nodes :
		var label = self.get_node(each)
		if label == null : continue
		self._set_text_to(label, translated)

# 重新註冊
func register_on_update () :
	if self.on_update_listener != null :
		self._get_i18n().off_update(self.on_update_listener)
	self.on_update_listener = self._get_i18n().on_update(self._update_listener)
	for each in self.on_update_tags :
		self.on_update_listener.tag(each)
	
# Private ====================

func _set_text_to (label: Control, str: String) :
	if label is RichTextLabel :
		label.text = str
	elif label is Label :
		label.text = str
	label.resized.emit()

func _get_i18n () :
	if self.i18n == null : 
		self.i18n = UREQ.acc(&"Uzil:i18n")
	return self.i18n

## 更新
func _update_listener (_ctrlr) :
	if self.update_mode != UpdateMode.ON_UPDATE : return
	self.update()
