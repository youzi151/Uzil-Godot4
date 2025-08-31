@tool
extends Node

## Control 主題設置
## 
## 從多個主題中, 把指定的屬性設置到目標Control上.
## 

# Variable ===================

## 目標
@export var targets : Array[Control] = []
var _targets  : Array[Control] = []

## 目標屬性
@export var target_properties : Array[String] = []

## 主題
@export var override_themes : Array[Theme] = []

@export var call_update := false :
	set (value) :
		call_update = false
		if value : self.update()

# GDScript ===================

func _ready () :
	self.update()

# Extends ====================

# Public =====================

## 刷新
func update () :
	self._do_targets(self._update)

# Private ====================

func _do_targets (fn: Callable) :
	var slf = self
	if slf is Control :
		fn.call(slf)
	for each in self.targets :
		fn.call(each)
	

func _update (target: Control) :
	var target_typ : StringName = target.get_class()
	
	var themes : Array = self.override_themes
	if target.theme != null :
		themes = override_themes.duplicate()
		themes.push_back(target.theme)
	
	for each in self.target_properties :
		var typs : PackedStringArray
		
		var prop : StringName = each
		
		# 若 屬性中有指定類別 則 取用
		if prop.contains(":") :
			typs = prop.split(":")
			var last_idx := typs.size()-1
			prop = typs[last_idx]
			typs[last_idx] = str(target_typ)
		# 否則 取目標的類別
		else :
			typs = PackedStringArray([target_typ])
		
		# 目標屬性
		var dst : StringName = prop
		# 若有指定要設置到的目標屬性 則 取用
		if prop.contains(">") :
			var p_arr := prop.split(">")
			prop = p_arr[0]
			dst = p_arr[1]
		
		# 設置 主題
		for theme in themes :
			if theme == null : continue
			for typ in typs :
				#print("prop[%s] typ[%s] dst[%s] " % [prop, typ, dst])
				
				# 設置 顏色
				if theme.has_color(prop, typ) :
					target.set(dst, theme.get_color(prop, typ))
				if theme.has_color(prop, &"_") :
					target.set(dst, theme.get_color(prop, &"_"))
				
				# TODO 設置 其他
