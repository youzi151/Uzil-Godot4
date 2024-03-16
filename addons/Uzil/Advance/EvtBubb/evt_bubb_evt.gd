extends Object

# Variable ===================

var name : String = ""

var tags : Array[String] = []

var is_handled : bool = false

var data : Dictionary = {}

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

func is_ignore (handler) :
	return false

func handled () :
	self.is_handled = true

# Private ====================
