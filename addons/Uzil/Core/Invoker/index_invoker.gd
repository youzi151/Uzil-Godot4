# desc ==========

## 索引 Invoker 呼叫器
## 
## 管理 間隔呼叫、每幀呼叫、延遲呼叫...等等
## 

# const =========

## Uzil
var Uzil

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

## 管理
var Mgr
## 實體
var Inst
## 任務
var Task

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.Uzil = Uzil
	self.PATH = _parent_index.PATH.path_join("Invoker")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Core.Invoker", self._target_index, {
		"alias" : ["Invoker"],
	})
	
	# 綁定 呼叫器管理
	UREQ.bind("Uzil", "invoker_mgr", self._target_mgr, {
		"alias" : ["invoker"],
		"requires" : ["Core.Invoker"],
	})
	
	return self

func _target_index () :
	self.Task = self.Uzil.load_script(self.PATH.path_join("invoker_task.gd"))
	self.Inst = self.Uzil.load_script(self.PATH.path_join("invoker_inst.gd"))
	self.Mgr = self.Uzil.load_script(self.PATH.path_join("invoker_mgr.gd"))
	return self

func _target_mgr () :
	var target = self.Mgr.new(null)
	target.name = "invoker_mgr"
	self.Uzil.add_child(target)
	return target
