@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const AUTOLOAD_NAME = "G"

func _enter_tree():
	# Initialization of the plugin goes here.
	self.add_autoload_singleton(AUTOLOAD_NAME, "res://addons/GlobalUtil/Scripts/global_util.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(AUTOLOAD_NAME)
