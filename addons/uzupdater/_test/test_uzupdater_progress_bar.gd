extends Node

# Variable ===================

@export
var bg : Control = null

@export
var inner : Control = null

@export
var label : RichTextLabel = null

# GDScript ===================

func _ready():
	pass

# Extends ====================

# Public =====================

func set_text (text) :
	self.label.text = text

func set_progress (progress) :
	self.inner.size.x = max(0.0, min(1.0, progress)) * self.bg.size.x

# Private ====================
