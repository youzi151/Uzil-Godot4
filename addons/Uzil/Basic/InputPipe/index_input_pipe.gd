# desc ==========

## 索引 InputPipe 輸入通道
##
## 可分層設置 操作配置 與 輸入轉換 ... 等的操作信號系統
## 

# const =========

## 路徑
var PATH : String

## 輸入器 實體
var Inst
## 層級
var Layer
## 處理器
var Handler
## 訊息
var Msg
## 設定
var Setting

# sub_index =====

# inst ==========

## 實體
var _inst

# other =========

## 腳本
var name_to_handler_script := {}

## 自帶 處理器 腳本 (名稱:腳本路徑)
var default_handler_scripts := {
	"key": "handlers/input_pipe_handler_key.gd",
	"keyconvert": "handlers/input_pipe_handler_key_convert.gd",
}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("InputPipe")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Basic.InputPipe",
		func():
			self.Setting = Uzil.load_script(self.PATH.path_join("input_pipe_setting.gd"))
			self.Msg = Uzil.load_script(self.PATH.path_join("input_pipe_msg.gd"))
			self.Layer = Uzil.load_script(self.PATH.path_join("input_pipe_layer.gd"))
			self.Handler = Uzil.load_script(self.PATH.path_join("input_pipe_handler.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("input_pipe_inst.gd"))
			
			for key in self.default_handler_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_handler_scripts[key]))
				self.import_handler_script(key, script)
				
			return self, 
		{
			"alias" : ["InputPipe"],
		}
	)
	
	# 綁定 實體
	UREQ.bind("Uzil", "input_pipe", 
		func():
			var target = self.get_inst()
			target.name = "input_pipe"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["inputpipe"],
			"requires" : ["Basic.InputPipe"],
		}
	)
	
	return self

## 取得 實體
func get_inst () :
	if self._inst : return self._inst
	
	var setting = self.Setting.load_from_file("keybinding.cfg")
	
	self._inst = self.Inst.new(setting)
	
	return self._inst

## 匯入 處理器 腳本
func import_handler_script (import_name, path_or_script) :
	self.name_to_handler_script[import_name] = path_or_script

## 取得 處理器 腳本
func get_handler_script (name_or_path) :
	var Util = UREQ.acc("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_handler_script, name_or_path)

## 建立 新 處理器
func new_handler (id, name_or_path, data) :
	var script = self.get_handler_script(name_or_path)
	if script == null : return null
	var strat = script.new()
	if strat == null : return null
	
	var handler = self.Handler.new(strat)
	handler.id = id
	handler.load_memo(data)
	return handler
