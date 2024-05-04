# desc ==========

## 索引 States 狀態機
##
## 簡單實現狀態機, 方便使用.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Mgr
## 實體
var Inst
## 狀態
var State

# inst ==========

# other =========

## 腳本
var name_to_state_script := {}

## 自帶 State 腳本 (名稱:腳本路徑)
var default_state_scripts := {
	"print" : "strats/state_print.gd",
	"pagecard_query" : "strats/state_pagecard_query.gd",
}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("States")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Advance.States",
		func():
			self.Mgr = Uzil.load_script(self.PATH.path_join("states_mgr.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("states_inst.gd"))
			self.State = Uzil.load_script(self.PATH.path_join("states_state.gd"))
			
			for key in self.default_state_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_state_scripts[key]))
				self.import_state_script(key, script)
			
			return self,
		{
			"alias" : ["States"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind("Uzil", "states",
		func():
			var target = self.Mgr.new(null)
			target.name = "states"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["states", "states_mgr"],
			"requires" : ["Advance.States"],
		}
	)
	return self

## 匯入 狀態 腳本
func import_state_script (import_name, path_or_script) :
	self.name_to_state_script[import_name] = path_or_script

## 取得 狀態 腳本
func get_state_script (name_or_path) :
	var Util = UREQ.acc("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_state_script, name_or_path)
