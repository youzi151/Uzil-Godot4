

# Variable ===================

## 索引
var Handlers

## 辨識
var id : String = ""

## id:處理器路徑 表
var _id_to_handler_path : Dictionary = {}
## id:處理器 表
var _id_to_handler : Dictionary = {}

## 格式化路徑 方法
var format_path_fn : Callable

## 取得 處理器 方法
var get_handler_script_fn : Callable

# GDScript ===================

func _init (index_Handlers) :
	self.Handlers = index_Handlers

# Extends ====================

# Interface ==================

# Public =====================

## 設置 處理器
func set_handler_path (id: String, handler_path: String) :
	if handler_path == "" :
		self._id_to_handler_path.erase(id)
	else :
		self._id_to_handler_path[id] = handler_path

## 取得 處理器
func get_handler (name_or_path: String) :
	name_or_path = self._prepare_handler_path(name_or_path)
	
	if self._id_to_handler.has(name_or_path) :
		return self._id_to_handler[name_or_path]
	
	var script = self._get_handler_script(name_or_path)
	if script == null : return null
	
	var handler = script.new()
	self._id_to_handler[name_or_path] = handler
	
	return handler

## 新建 處理器
func new_handler (name_or_path: String) :
	name_or_path = self._prepare_handler_path(name_or_path)
	
	var script = self._get_handler_script(name_or_path)
	if script == null : return null
	
	var handler = script.new()
	return handler

## 讀取 處理器 設定檔
func load_handlers (path: String) :
	var id_to_path : Dictionary = UREQ.acc(&"Uzil:Util").config.load_cfg_dict(path)
	for id in id_to_path :
		self.set_handler_path(id, id_to_path[id])

## 呼叫 處理器
func call_method (handler_ids: Array, method: StringName, args := [], opts := {}) :
	var handlers := []
	for each in handler_ids :
		var handler = self.get_handler(each)
		if handler == null :
			G.error("handler[%s] not found." % [each])
			continue
		handlers.push_back(handler)
	return await self.Handlers.util.call_method(handlers, method, args, opts)

## 執行 處理器
func handle (handler_ids: Array, tags: Array, data := {}, opts := {}) :
	var handlers := []
	for each in handler_ids :
		var handler = self.get_handler(each)
		if handler == null :
			G.error("handler[%s] not found." % [each])
			continue
		handlers.push_back(handler)
	return await self.Handlers.util.handle(handlers, tags, data, opts)


# Private ====================

func _prepare_handler_path (name_or_path: String) :
	
	if self._id_to_handler_path.has(name_or_path) :
		name_or_path = self._id_to_handler_path[name_or_path]
	
	if not self.format_path_fn.is_null() :
		var formated = self.format_path_fn.call(name_or_path)
		if formated != null :
			name_or_path = formated
	
	return name_or_path

func _get_handler_script (name_or_path: String) :
	var Uzil = UREQ.acc(&"Uzil:Uzil")
	var script = null
	
	if not self.get_handler_script_fn.is_null() :
		script = self.get_handler_script_fn.call(name_or_path)
	else :
		script = Uzil.load_script(name_or_path)
	
	return script
