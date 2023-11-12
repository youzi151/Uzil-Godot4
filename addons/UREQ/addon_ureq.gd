@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
# 特殊用途, 需要較高辨識度. 故全大寫.
const AUTOLOAD_NAME = "UREQ"

func _enter_tree():
	# Initialization of the plugin goes here.
	self.add_autoload_singleton(AUTOLOAD_NAME, "res://addons/UREQ/Scripts/ureq.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(AUTOLOAD_NAME)
