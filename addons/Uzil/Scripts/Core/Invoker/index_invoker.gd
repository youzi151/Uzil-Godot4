# desc ==========

## 索引 Invoker 呼叫器
## 
## 管理 間隔呼叫、每幀呼叫、延遲呼叫...等等
## 

# const =========

## 路徑
var PATH : String

## 呼叫類型
const CALLTYPE = {
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
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Invoker")
	
	self.Task = G.v.Uzil.load_script(self.PATH.path_join("invoker_task.gd"))
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("invoker_inst.gd"))
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("invoker_mgr.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
