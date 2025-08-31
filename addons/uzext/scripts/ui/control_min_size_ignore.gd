@tool
extends Control

# Variable ===================

@export
var is_ignore_minimum_size_x := false
@export
var is_ignore_minimum_size_y := false

# GDScript ===================

func _get_minimum_size () :
	var _size := self.custom_minimum_size
	var m_size := _size
	
	for each in self.get_children() :
		if not (each is Control) : continue
		var each_msize : Vector2 = each.get_combined_minimum_size()
		m_size = m_size.max(each_msize)
	
	if self.is_ignore_minimum_size_x :
		m_size.x = _size.x
	if self.is_ignore_minimum_size_y :
		m_size.y = _size.y
	
	return m_size

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================
