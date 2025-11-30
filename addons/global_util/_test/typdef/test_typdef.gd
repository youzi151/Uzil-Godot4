extends Control

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export
var def_dicts_edit : TextEdit = null

@export
var target_node : Node = null

@export
var target_dict_edit : TextEdit = null

# Extends ====================

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_typdef")

func _exit_tree () :
	G.off_print("test_typdef")

# Public =====================

func test_normal () :
	
	
	var def_dicts : Dictionary = JSON.parse_string(self.def_dicts_edit.text)
	for def_name in def_dicts :
		var def_dict : Dictionary = def_dicts[def_name]
		G.typ.undef(def_name)
		G.typ.define(def_name, def_dict)
	
	var target_dict := JSON.parse_string(self.target_dict_edit.text)
	G.print("compare target_dict : %s %s" % [
		G.typ.mtch(&"DefDict", target_dict),
		G.typ.diff(&"DefDict", target_dict),
	])
	G.print("compare target_obj : %s %s" % [
		G.typ.mtch(&"DefObj", self.target_node),
		G.typ.diff(&"DefObj", self.target_node),
	])
	
	if def_dicts.has("_def_dict") :
		var def_without_define : Dictionary = def_dicts["_def_dict"]
		G.print("compare target_dict with def_dict : %s %s" % [
			G.typ.mtch(def_without_define, target_dict),
			G.typ.diff(def_without_define, target_dict),
		])
	
	for def_name in def_dicts :
		var def_dict : Dictionary = def_dicts[def_name]
		G.typ.undef(def_name)
