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
## 管理
var Mgr

# inst ==========

# other =========

## 是否影響到Godot本身的Process
var is_effect_to_godot_process := true

## 是否已經影響Godot本身的Process
var _is_godot_process_effected := false

## 是否 背景計時 (設定)
var is_timing_in_background_config := false

# func ==========

## 建立索引
func index (_parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Times")
	
	self.Inst = G.v.Uzil.load_script(self.PATH.path_join("times_inst.gd"))
	self.Mgr = G.v.Uzil.load_script(self.PATH.path_join("times_mgr.gd"))
	
	return self

## 初始化
func init (_parent_index) :
	
	G.v.Uzil.on_notification.on(func test (_ctrlr):
		if not self.is_effect_to_godot_process : return
		
		var what = _ctrlr.data["what"]
		match what :
			MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN :
				if self._is_godot_process_effected :
					self._is_godot_process_effected = false
					G.v.Uzil.get_tree().paused = false
					
			MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT :
				if not self._is_godot_process_effected :
					self._is_godot_process_effected = true
					G.v.Uzil.get_tree().paused = true
	)
	
	return self
