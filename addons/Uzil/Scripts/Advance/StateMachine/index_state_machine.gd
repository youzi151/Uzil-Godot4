# desc ==========

## 索引 StateMachine 狀態機
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
	"print" : "states/state_print.gd",
	"pagecard_switch_deck" : "states/state_pagecard_switch_deck.gd",
}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("StateMachine")
	
	# 綁定 索引
	UREQ.bind_g("Uzil", "Advance.StateMachine",
		func () :
			self.Mgr = Uzil.load_script(self.PATH.path_join("state_machine_mgr.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("state_machine_inst.gd"))
			self.State = Uzil.load_script(self.PATH.path_join("state_machine_state.gd"))
			
			for key in self.default_state_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_state_scripts[key]))
				self.import_state_script(key, script)
			
			return self,
		{
			"alias" : ["StateMachine", "States"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind_g("Uzil", "state_machine",
		func () :
			var target = self.Mgr.new(null)
			target.name = "state_machine"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["states", "states_mgr"],
			"requires" : ["Advance.StateMachine"],
		}
	)
	return self

## 匯入 節點 腳本
func import_state_script (import_name, path_or_script) :
	self.name_to_state_script[import_name] = path_or_script

## 取得 節點 腳本
func get_state_script (name_or_path) :
	var Util = UREQ.access_g("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_state_script, name_or_path)
