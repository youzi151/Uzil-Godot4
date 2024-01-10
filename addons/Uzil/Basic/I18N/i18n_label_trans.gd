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

## 更新事件標籤
@export var on_update_tags : Array[String] = []

## 要代換的文字UI
@export var label_nodes : Array[NodePath] = []


## 更新 偵聽者
var on_update_listener = null

# GDScript ===================

func _init () :
	pass

func _ready () :
	var Uzil = UREQ.acc("Uzil", "Uzil")
	Uzil.once_ready(func () :
		self.i18n = UREQ.acc("Uzil", "i18n")
	
		# 註冊 當 多語系更新時 更新
		self.register_on_update()
		
		# 首次更新
		self.update()
	)

func _exit_tree () :
	# 註銷 當 多語系更新時 更新
	if self.on_update_listener != null :
		self.i18n.off_update(self.on_update_listener)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	if self.update_mode == UpdateMode.PROCESS :
		self.update()

# Extends ====================

# Public =====================

## 更新
func update () :
	var translated = self.i18n.trans(self.raw_text)
	for each in self.label_nodes :
		var label = self.get_node(each)
		if label == null : continue
		if label is RichTextLabel :
			label.text = translated
		elif label is Label :
			label.text = translated

# 重新註冊
func register_on_update () :
	if self.on_update_listener != null :
		self.i18n.off_update(self.on_update_listener)
	self.on_update_listener = self.i18n.on_update(self._update_listener)
	for each in self.on_update_tags :
		self.on_update_listener.tag(each)
	
# Private ====================

## 更新
func _update_listener (_ctrlr) :
	if self.update_mode != UpdateMode.ON_UPDATE : return
	self.update()
