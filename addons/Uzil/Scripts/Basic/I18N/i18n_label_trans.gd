extends Node

## i18n label trans 文字UI翻譯
##
## 提供快速設置代換文字到文字UI上.
##

var i18n

# Variable ===================

## 要代換的文字UI
@export var label_nodes : Array[NodePath] = []

## 原始文字
@export_multiline var raw_text : String = ""

## 更新 偵聽者
var on_update_listener = null

# GDScript ===================

func _init (_dont_set_in_scene) :
	pass

func _enter_tree () :
	var Uzil = UREQ.access_g("Uzil", "Uzil")
	Uzil.once_ready(self._on_ready)
	pass

func _exit_tree () :
	# 註銷 當 多語系更新時 更新
	self.i18n.off_update(self.on_update_listener)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	pass

# Extends ====================

# Public =====================

## 更新
func update_listener (_ctrlr) :
	var translated = self.i18n.trans(self.raw_text)
	for each in self.label_nodes :
		var label = self.get_node(each)
		if label == null : continue
		if label is RichTextLabel :
			label.text = translated
		elif label is Label :
			label.text = translated
	

# Private ====================

func _on_ready () :
	
	self.i18n = UREQ.access_g("Uzil", "i18n")
	
	# 註冊 當 多語系更新時 更新
	self.on_update_listener = self.i18n.on_update(self.update_listener)
	self.update_listener(null)
