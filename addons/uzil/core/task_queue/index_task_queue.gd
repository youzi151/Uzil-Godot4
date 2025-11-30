# desc ==========

## 索引 TaskQueue 行動柱列
##
## 依序執行行動內容
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實例
var Inst
## 任務
var Task

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("task_queue")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.TaskQueue",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("task_queue_inst.gd"))
			self.Task = Uzil.load_script(self.PATH.path_join("task_queue_task.gd"))
			return self,
		{
			"alias" : ["TaskQueue"]
		}
	)
	
		# 綁定 管理
	UREQ.bind(&"Uzil", &"task_queue_mgr", 
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Inst.new(),
			)
			Uzil.request_node("Core/TaskQueue", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : ["task_queue"],
			"requires" : ["Util"],
		}
	)
	
