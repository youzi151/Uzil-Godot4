# desc ==========

## 索引 States 狀態機
##
## 狀態機, 流程控制用.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Inst
## 執行個體
var Runtime
## 狀態
var State
## 轉場
var Transition
## 條件
var Condition

# inst ==========

# other =========

## 腳本
var name_to_handler_state := {}
var name_to_handler_transition := {}
var name_to_handler_condition := {}

## 自帶 State 腳本 (名稱:腳本路徑)
var default_handlers_state := {
	"print": "handlers_state/handler_state_print.gd",
	"pagecard_query": "handlers_state/handler_state_pagecard_query.gd",
}
## 自帶 Transition 腳本 (名稱:腳本路徑)
var default_handlers_transition := {
	"wait_sec": "handlers_transition/handler_transition_wait_sec.gd"
}
## 自帶 Condition 腳本 (名稱:腳本路徑)
var default_handlers_condition := {
	"vars_equals" : "handlers_condition/handler_condition_vars_equals.gd",
}


# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("States")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Advance.States",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("states_inst.gd"))
			self.Runtime = Uzil.load_script(self.PATH.path_join("states_runtime.gd"))
			self.State = Uzil.load_script(self.PATH.path_join("states_state.gd"))
			self.Transition = Uzil.load_script(self.PATH.path_join("states_transition.gd"))
			self.Condition = Uzil.load_script(self.PATH.path_join("states_condition.gd"))
			
			for key in self.default_handlers_state :
				var script = Uzil.load_script(self.PATH.path_join(self.default_handlers_state[key]))
				self.import_handler_state(key, script)
			
			for key in self.default_handlers_transition :
				var script = Uzil.load_script(self.PATH.path_join(self.default_handlers_transition[key]))
				self.import_handler_transition(key, script)
			
			for key in self.default_handlers_condition :
				var script = Uzil.load_script(self.PATH.path_join(self.default_handlers_condition[key]))
				self.import_handler_condition(key, script)
			
			return self,
		{
			"alias" : ["States"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind(&"Uzil", &"states",
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Inst.new(),
			)
			Uzil.request_node("Advance/States", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : ["states", "states_mgr"],
			"requires" : ["Util", "Advance.States"],
		}
	)
	return self

## 匯入 狀態 腳本
func import_handler_state (import_name: String, path_or_script) :
	self.name_to_handler_state[import_name] = path_or_script

## 取得 狀態 腳本
func get_handler_state (name_or_path: String) :
	var Util = UREQ.acc(&"Uzil:Util")
	return Util.gdscript.get_script_from_dict(self.name_to_handler_state, name_or_path)

## 匯入 轉場 腳本
func import_handler_transition (import_name: String, path_or_script) :
	self.name_to_handler_transition[import_name] = path_or_script

## 取得 轉場 腳本
func get_handler_transition (name_or_path: String) :
	var Util = UREQ.acc(&"Uzil:Util")
	return Util.gdscript.get_script_from_dict(self.name_to_handler_transition, name_or_path)

## 匯入 條件 腳本
func import_handler_condition (import_name: String, path_or_script) :
	self.name_to_handler_condition[import_name] = path_or_script

## 取得 條件 腳本
func get_handler_condition (name_or_path: String) :
	var Util = UREQ.acc(&"Uzil:Util")
	return Util.gdscript.get_script_from_dict(self.name_to_handler_condition, name_or_path)
