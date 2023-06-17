
## InputPipe.Setting 輸入管道 設定
##
## 提供 讀取/儲存 檔案中的 輸入處理器 設定. [br]
## 或 提供操作 來 變更設定 並 同步到輸入管道實體.
## 

# Static =====================

## 讀取 預設
static func load_from_file (path) :
	
	var setting = new()
	
	var user_save = UREQ.access_g("Uzil", "user_save")
	
	var setting_data = user_save.user.read(path)
	if setting_data != null :
		for handler_id in setting_data :
			var data = setting_data[handler_id]
			setting.set_setting(handler_id, data)
	
	return setting

# Variable ===================

## 實體
var _inst = null

## 是否啟用
var handdler_to_setting := {}

# GDScript ===================

# Extends ====================

# Public =====================

## 設置 實體
func set_inst (inst) :
	self._inst = inst

## 取得 設定
func get_setting (handler_id : String) :
	if self.handdler_to_setting.has(handler_id) == false : 
		return null
	return self.handdler_to_setting[handler_id]


## 設置 設定
func set_setting (handler_id : String, data : Dictionary) :
	self.handdler_to_setting[handler_id] = data
	for layer in self._inst.get_layers() :
		var handler = layer.get_handler(handler_id)
		if handler == null :
			continue
		handler.load_memo(data)


## 覆寫 設定
func override_setting (handler_id : String, data : Dictionary) :
	var exist : Dictionary
	if (self.handdler_to_setting.has(handler_id)) :
		exist = self.handdler_to_setting[handler_id]
		exist.merge(data, true)
	else :
		exist = data
		
	self.set_setting(handler_id, exist)

