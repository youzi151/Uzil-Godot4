# desc ==========

## 索引 Invoker 呼叫器
## 
## 管理 間隔呼叫、每幀呼叫、延遲呼叫...等等
## 

# const =========

## 路徑
var PATH : String

## 呼叫類型
const CallType = {
	"ONCE" = 0,
	"INTERVAL" = 1,
	"UPDATE" = 2,
	"FRAME" = 3
}

# sub_index =====

## 實體
var Inst
## 任務
var Task

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	self.PATH = _parent_index.PATH.path_join("Invoker")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.Invoker", 
		func():
			self.Task = Uzil.load_script(self.PATH.path_join("invoker_task.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("invoker_inst.gd"))
			return self,
		{
			"alias" : ["Invoker"],
		}
	)
	
	# 綁定 呼叫器管理
	UREQ.bind(&"Uzil", &"invoker_mgr", 
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Inst.new(key),
				func(inst):
					inst.clear(),
			)
			mgr.is_call_process = true
			Uzil.request_node("Core/Invoker", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : [],
			"requires" : ["Util", "Core.Invoker"],
		}
	)
	
	# 綁定 實體
	UREQ.bind(&"Uzil", &"invoker", 
		func():
			var mgr = UREQ.acc(&"Uzil:invoker_mgr")
			return mgr.inst(),
		{
			"alias" : [],
			"requires" : ["invoker_mgr"],
		}
	)
	
	return self
