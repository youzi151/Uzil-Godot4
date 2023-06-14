# desc ==========

## 索引 Times 多重時間
##
## 提供多個 時間實體/時間軸 來 非單一的暫停與恢復計時.
##

# const =========

## Uzil
var Uzil

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
func index (Uzil, _parent_index) :
	
	self.Uzil = Uzil
	self.PATH = _parent_index.PATH.path_join("Times")
	
	# 綁定 索引
	UREQ.bind_g("Uzil", "Core.Times", self._target_index, {
		"alias" : ["Times"],
	})
	
	# 綁定 實體管理
	UREQ.bind_g("Uzil", "times_mgr", self._target_mgr, {
		"alias" : ["times"],
		"requires" : ["Core.Times"],
	})
	
	return self

func _target_mgr () :
	var target = self.Mgr.new(null)
	target.name = "times_mgr"
	self.Uzil.add_child(target)
	return target

func _target_index () :
	self.Inst = self.Uzil.load_script(self.PATH.path_join("times_inst.gd"))
	self.Mgr = self.Uzil.load_script(self.PATH.path_join("times_mgr.gd"))
	
	self.Uzil.on_notification.on(func (_ctrlr):
		if not self.is_effect_to_godot_process : return
		
		var what = _ctrlr.data["what"]
		match what :
			MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN :
				if self._is_godot_process_effected :
					self._is_godot_process_effected = false
					self.Uzil.get_tree().paused = false
					
			MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT :
				if not self._is_godot_process_effected :
					self._is_godot_process_effected = true
					self.Uzil.get_tree().paused = true
	)
	
	return self
