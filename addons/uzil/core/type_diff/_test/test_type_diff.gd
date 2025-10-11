extends Control

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export
var type_def : TextEdit = null

@export
var target_node : Node = null

@export
var target_dict : TextEdit = null

# Extends ====================

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_typediff")
	
	var typediff = UREQ.acc(&"Uzil:type_diff")
	typediff.set_def(&"Profile", {"nickname":TYPE_STRING})

func _exit_tree () :
	G.off_print("test_typediff")

# Public =====================

func test_normal () :
	var typediff = UREQ.acc(&"Uzil:type_diff")
	typediff.del_def(&"MyClass")
	typediff.set_def(&"MyClass", JSON.parse_string(self.type_def.text))
	G.print("compare target node : %s" % [typediff.compare(&"MyClass", self.target_node)])
	G.print("compare target dict : %s" % [typediff.compare(&"MyClass", JSON.parse_string(self.target_dict.text))])
