extends Node

# Variable ===================

@export var bg_npath : NodePath = ""
var bg : Control = null

@export var inner_npath : NodePath = ""
var inner : Control = null

@export var label_npath : NodePath = ""
var label : RichTextLabel = null

# GDScript ===================

func _ready():
	self.bg = self.get_node(self.bg_npath)
	self.inner = self.get_node(self.inner_npath)
	self.label = self.get_node(self.label_npath)

# Extends ====================

# Public =====================

func set_text (text) :
	self.label.text = text

func set_progress (progress) :
	self.inner.size.x = max(0.0, min(1.0, progress)) * self.bg.size.x

# Private ====================

