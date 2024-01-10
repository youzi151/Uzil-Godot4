# desc ==========

## 索引 Flow 流程控制
##
## 以節點式串接的流程控制工具 [br]
## 將 執行內容 與 串接條件 設置於 節點上 [br]
## 每個節點 會在 完成 該節點持有的條件 後 進入 後續節點
## 

var Util

# const =========

## 路徑
var PATH : String

## 啟用狀態
enum ActiveState {
	INACTIVE,
	ACTIVE,
	PAUSE,
	COMPLETE
}

# sub_index =====

## 管理
var Mgr
## 流程器 實體
var Inst
## 條件
var Gate
## 事件
var Event
## 節點
var Chain

# inst ==========

# other =========

## 腳本
var name_to_chain_script := {}
var name_to_event_script := {}
var name_to_gate_script := {}

## 自帶 Chain 腳本 (名稱:腳本路徑)
var default_chain_scripts := {
	"base": "chains/flow_chain_base.gd"
}
## 自帶 Event 腳本 (名稱:腳本路徑)
var default_event_scripts := {
	"print": "events/flow_event_print.gd"
}
## 自帶 Gate 腳本 (名稱:腳本路徑)
var default_gate_scripts := {
	"time": "gates/flow_gate_time.gd"
}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Flow")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Basic.Flow", 
		func () :
			
			self.Gate = Uzil.load_script(self.PATH.path_join("flow_gate.gd"))
			self.Event = Uzil.load_script(self.PATH.path_join("flow_event.gd"))
			self.Chain = Uzil.load_script(self.PATH.path_join("flow_chain.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("flow_inst.gd"))
			self.Mgr = Uzil.load_script(self.PATH.path_join("flow_mgr.gd"))
			
			for key in self.default_chain_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_chain_scripts[key]))
				self.import_chain_script(key, script)
			
			for key in self.default_event_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_event_scripts[key]))
				self.import_event_script(key, script)
			
			for key in self.default_gate_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_gate_scripts[key]))
				self.import_gate_script(key, script)
			
			return self,
		{
			"alias" : ["Flow"]
		}
	)
	
	# 綁定 實體
	UREQ.bind("Uzil", "flow_mgr", 
		func () :
			var target = self.Mgr.new(null)
			target.name = "flow_mgr"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["flow"],
			"requires" : ["Basic.Flow"],
		}
	)
	
	return self

## 匯入 節點 腳本
func import_chain_script (import_name, path_or_script) :
	self.name_to_chain_script[import_name] = path_or_script

## 匯入 事件 腳本
func import_event_script (import_name, path_or_script) :
	self.name_to_event_script[import_name] = path_or_script

## 匯入 條件 腳本
func import_gate_script (import_name, path_or_script) :
	self.name_to_gate_script[import_name] = path_or_script

## 取得 節點 腳本
func get_chain_script (name_or_path) :
	var Util = UREQ.acc("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_chain_script, name_or_path)

## 取得 事件 腳本
func get_event_script (name_or_path) :
	var Util = UREQ.acc("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_event_script, name_or_path)

## 取得 條件 腳本
func get_gate_script (name_or_path) :
	var Util = UREQ.acc("Uzil", "Util")
	return Util.gdscript.get_script_from_dict(self.name_to_gate_script, name_or_path)
