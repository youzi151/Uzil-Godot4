@tool
extends Node

## 設置類型
enum StratSetType {
	# 腳本ID
	SCRIPT_ID,
	# 腳本資源
	SCRIPT_RES,
}

# Variable ===================

## 辨識 (若 留空 則 取node.name)
@export
var id : String = ""

## 腳本設置類型
@export
var strat_set_type : StratSetType = StratSetType.SCRIPT_ID :
	set (value) : 
		strat_set_type = value
		self.notify_property_list_changed()

## 面板設置 策略
@export
var strat_id := ""

## 面板設置 策略
@export
var strat_script : GDScript = null

## 是否自動轉換NodePath
@export
var is_auto_convert_node_path : bool = true

## 資料
@export
var data : Dictionary = {}

## 實體
var state = null

# GDScript ===================

func _ready () :
	if Engine.is_editor_hint() : return
	self.request_state()

func _validate_property (property: Dictionary) :
	match property.name : 
		"strat_id" :
			match self.strat_set_type : 
				StratSetType.SCRIPT_ID :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR
		"strat_script" :
			match self.strat_set_type : 
				StratSetType.SCRIPT_RES :
					property.usage |= PROPERTY_USAGE_EDITOR
				_ :
					property.usage ^= PROPERTY_USAGE_EDITOR


# Extends ====================

# Public =====================

func request_state () :
	if self.state != null : 
		return self.state
	
	var State = UREQ.acc(&"Uzil:Advance.States").State
	match self.strat_set_type :
		StratSetType.SCRIPT_ID :
			self.state = State.new(self.strat_id)
		StratSetType.SCRIPT_RES :
			var start = null
			if self.strat_script != null :
				start = self.strat_script.new()
			self.state = State.new(start)
		
	if self.id == "" :
		self.state.id = self.name
	else :
		self.state.id = self.id
	
	# 建立一份新的, 避免在特定情況出現問題 :
	# 若此腳本的節點在PackedScene中, 可能會在instantiate後, 
	# 因為改動data中的資料, 影響到PackedScene中的此腳本節點的參數 (可從PackedScene._bundled看出)
	# 導致後續instantiate出來的實例中使用到同一份data. 
	# (可能是傳參考而非複製?)
	var new_data : Dictionary = {}
	
	if self.is_auto_convert_node_path :
		new_data = self._convert_node_path_to_node_in_dict(self.data)
	else :
		new_data = self.data.duplicate()
	
	self.state.set_data(new_data)
	
	return self.state

# Private ====================

## 轉換 字典中的 節點路徑 為 節點
func _convert_node_path_to_node_in_dict (data: Dictionary) :
	var new_data : Dictionary = {}
	for key in data :
		var each = data[key]
		match typeof(each) :
			TYPE_NODE_PATH :
				new_data[key] = self.get_node(each)
			TYPE_ARRAY :
				new_data[key] = self._convert_node_path_to_node_in_array(each)
			TYPE_DICTIONARY :
				new_data[key] = self._convert_node_path_to_node_in_dict(each)
			_ :
				new_data[key] = each
	return new_data

## 轉換 陣列中的 節點路徑 為 節點
func _convert_node_path_to_node_in_array (arr: Array) :
	var new_arr : Array = []
	for idx in arr.size() :
		var each = arr[idx]
		match typeof(each) :
			TYPE_NODE_PATH :
				new_arr.push_back(self.get_node(each))
			TYPE_ARRAY :
				new_arr.push_back(self._convert_node_path_to_node_in_array(each))
			TYPE_DICTIONARY :
				new_arr.push_back(self._convert_node_path_to_node_in_dict(each))
			_ :
				new_arr.push_back(each)
	return new_arr
