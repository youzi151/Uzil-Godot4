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
## 事件串管理
var BusMgr

# inst ==========

# other =========

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Evt")
	
	self.Listener = G.v.Uzil.load_script(self.PATH.path_join("evt_listener.gd"))
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("evt_inst.gd"))
	self.CallCtrlr = G.v.Uzil.load_script(self.PATH.path_join("evt_call_ctrlr.gd"))
	self.Bus = G.v.Uzil.load_script(self.PATH.path_join("evt_bus.gd"))
	self.BusMgr = G.v.Uzil.load_script(self.PATH.path_join("evt_bus_mgr.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	return self
