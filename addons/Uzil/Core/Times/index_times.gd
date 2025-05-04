# desc ==========

## 索引 Times 多重時間
##
## 提供多個 時間實體/時間軸 來 非單一的暫停與恢復計時.
##

# const =========

## 路徑
var PATH : String

## 優先度
var Priority := {
	CONFIG   =   0,
	OVERRIDE =  50,
	SYSTEM   = 100,
}

# sub_index =====

## 實體
var Inst

# inst ==========

# other =========

## 是否影響到Godot本身的Process
var is_effect_to_godot_process := true

## 是否已經影響Godot本身的Process
var _is_godot_process_effected := false

## 是否 背景暫停 (設定)
var is_pause_in_background_config := false

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Times")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Core.Times", 
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("times_inst.gd"))
			
			Uzil.on_notification.on(func(_ctrlr):
				if not self.is_effect_to_godot_process : return
				
				var what = _ctrlr.data["what"]
				match what :
					MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN :
						if self._is_godot_process_effected :
							self._is_godot_process_effected = false
							var window : Window = Uzil.get_tree().root
							window.process_mode = Node.PROCESS_MODE_PAUSABLE
							
					MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT :
						if not self._is_godot_process_effected :
							self._is_godot_process_effected = true
							var window : Window = Uzil.get_tree().root
							window.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			)
			
			return self
			,
		{
			"alias" : ["Times"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind(&"Uzil", &"times_mgr",
		func():
			var Util = UREQ.acc(&"Uzil:Util")
			var mgr = Util.InstMgr.new(
				func(key):
					var inst : Node = self.Inst.new(key)
					var name : String = str(key)
					inst.name = name if not name.is_empty() else "_"
					Uzil.request_node("Core/Times").add_child(inst)
					return inst,
			)
			mgr.is_call_process = true
			Uzil.request_node("Core/Times", Util.InstMgrNode, [mgr])
			return mgr,
		{
			"alias" : ["times"],
			"requires" : ["Util", "Core.Times"],
		}
	)
	
	return self
