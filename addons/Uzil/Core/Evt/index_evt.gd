# desc ==========

## 索引 事件
## 
## 提供 多域管理 與 事件串 與 事件 的 事件機制.[br]
## 若僅是簡單的事件註冊, 可使用signal就好.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 偵聽者
var Listener
## 事件
var Inst
## 呼叫控制項
var CallCtrlr
## 事件串
var Bus

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Evt")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.Evt",
		func():
			self.Listener = Uzil.load_script(self.PATH.path_join("evt_listener.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("evt_inst.gd"))
			self.CallCtrlr = Uzil.load_script(self.PATH.path_join("evt_call_ctrlr.gd"))
			self.Bus = Uzil.load_script(self.PATH.path_join("evt_bus.gd"))
			
			return self, 
		{
			"alias" : ["Evt"]
		}
	)
	
	# 綁定 管理
	UREQ.bind(&"Uzil", &"evt_bus_mgr", 
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					return self.Bus.new(),
			)
			Uzil.request_node("Core/Evt", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : [],
			"requires" : ["Util", "Core.Evt"],
		}
	)
	
	return self
