# desc ==========

## 索引 事件
## 
## 提供 多域管理 與 事件串 與 事件 的 事件機制.[br]
## 若僅是簡單的事件註冊, 可使用signal就好.
## 

# const =========

## 路徑
var PATH : String
## Uzil
var Uzil

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
func index (Uzil, _parent_index) :
	
	self.Uzil = Uzil
	self.PATH = _parent_index.PATH.path_join("Evt")
	
	# 綁定 索引
	UREQ.bind_g("Uzil", "Core.Evt", self._target_index, {
		"alias" : ["Evt"]
	})
	
	# 綁定 事件串管理
	UREQ.bind_g("Uzil", "evt_bus_mgr", self._target_mgr, {
		"alias" : ["evtbus", "evt_bus"],
		"requires" : ["Core.Evt"],
	})
	
	return self

func _target_index () :
	self.Listener = Uzil.load_script(self.PATH.path_join("evt_listener.gd"))
	self.Inst = Uzil.load_script(self.PATH.path_join("evt_inst.gd"))
	self.CallCtrlr = Uzil.load_script(self.PATH.path_join("evt_call_ctrlr.gd"))
	self.Bus = Uzil.load_script(self.PATH.path_join("evt_bus.gd"))
	self.BusMgr = Uzil.load_script(self.PATH.path_join("evt_bus_mgr.gd"))
	
	return self

func _target_mgr () :
	var target = self.BusMgr.new()
	target.name = "evt_bus_mgr"
	Uzil.add_child(target)
	return target
