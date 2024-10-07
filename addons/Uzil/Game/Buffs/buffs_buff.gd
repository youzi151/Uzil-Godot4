# Variable ===================

## 所屬Buffs實例
var _inst

## 辨識
var id : String = ""

## 標籤條件
var tag_conditions : Array = []

## 描述
var descs : Dictionary = {}

## 設定
var configs : Dictionary = {}

## 處理器
var handlers : Array = []

# GDScript ===================

func _to_string() -> String :
	return self.id

func _init (inst, _data: Dictionary = {}):
	self._inst = inst
	
	if _data.has("tag_conditions") :
		self.tag_conditions = _data["tag_conditions"]
		
	if _data.has("descs") :
		self.descs = _data["descs"].duplicate(true)
	
	if _data.has("configs") :
		self.configs = _data["configs"].duplicate(true)
	
	if _data.has("handlers") :
		self.set_handlers(_data["handlers"])

# Extends ====================

# Interface ==================

# Public =====================

## 設置 處理器
func set_handlers (handler_ids: Array) :
	self.handlers.clear()
	for each in handler_ids :
		self.handlers.push_back(each)

## 執行附加狀態
func do_buff (tags: Array, data: Dictionary, opts: Dictionary) :
	if self.handlers.size() == 0 : return data
	
	var handlers_buff = self._inst.get_handlers_inst()
	
	var ctrlr = handlers_buff.handle(self.handlers, tags, data, opts)
	if ctrlr.result != null :
		return ctrlr.result
	
	return data

## 有無 描述
func has_desc (key: String) :
	return self.descs.has(key)

## 取得 描述
func get_desc (key: String, _default_val = null) :
	if not self.descs.has(key) : return _default_val
	return self.descs[key]

## 有無 設定
func has_cfg (key: String) :
	return self.configs.has(key)

## 取得 設定
func get_cfg (key: String, _default_val = null) :
	if not self.configs.has(key) : return _default_val
	return self.configs[key]

# Private ====================
