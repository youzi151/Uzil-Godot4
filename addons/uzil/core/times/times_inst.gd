extends Node

## Times 時間 實體
##
## 代表一個時間軸的時間實體, 可暫停/恢復計時.
##

# Variable ===================

## 是否 在背景執行時暫停 (失去焦點時不計時) 多重數值
var _is_pause_in_background_vals = null

## 是否暫停 多重數值
var _is_pause_vals = null

## 時間比例 多重數值
var _time_scale_vals = null

## 當前時間 (毫秒)
var _time := 0

## 起始時間 (毫秒)
var _start_time := 0

## 當幀時間差(豪秒)
var _delta_time := 0
var _delta_time_sec := 0.0

## 前一幀時間 (毫秒)
var _last_time := 0

## 是否使用時間差
var is_use_default_dt := false

## 暫停後多出來的時間
var _time_since_pause := 0

var _last_is_paused := false

## 當 暫停改變
var on_pause_change : RefCounted

# Extends ====================

# GDScript ===================

func _init (_dont_set_in_scene) :
	var Vals = UREQ.acc(&"Uzil:Core.Vals")
	var Times = UREQ.acc(&"Uzil:Core.Times")
	
	self.on_pause_change = UREQ.acc(&"Uzil:Core.Evt").Inst.new()
	
	self._time_scale_vals = Vals.new()
	self._is_pause_in_background_vals = Vals.new()
	self._is_pause_vals = Vals.new()
	
	self._start_time = self._get_sys_time()
	self._last_time = self._start_time
	
	self._time_scale_vals.set_default(1.0)
	self._is_pause_in_background_vals.set_default(true)
	self._is_pause_vals.set_default(false)
	self._is_pause_vals.on_update.on(self._on_pause_update)
	
	self._last_is_paused = self.is_paused()
	
	self._is_pause_in_background_vals.set_data(
		"CONFIG",
		func(): return Times.is_pause_in_background_config,
		Times.Priority.CONFIG
	)

func _notification (msg) :
	match msg :
		# 進入焦點
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN : 
			self._is_pause_vals.del_data("_system")
		# 離開焦點
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT : 
			# 若在 背景中不暫停 則 忽略
			if not self._is_pause_in_background_vals.current() : return
			self._is_pause_vals.set_data("_system", true, INF)
		
# Public =====================

## 推進
func process (_dt = 0.0) :
	if self._is_pause_vals.current() : return
	
	var sys_time = self._get_sys_time()
	
	if is_use_default_dt :
		self._delta_time = _dt * 1000
		self._delta_time_sec = _dt
		self._last_time = self._time
	else :
		self._delta_time = (sys_time - self._last_time) * self._time_scale_vals.current()
		self._delta_time_sec = float(self._delta_time) * 0.001
		self._last_time = sys_time
	
	self._time = self._time + self._delta_time

## 是否暫停中
func is_paused () :
	return self._is_pause_vals.current()

## 取得 當前時間 (豪秒)
func now () :
	return self._time

## 取得 該幀時間差 (豪秒)
func dt () -> int :
	return self._delta_time

## 取得 該幀時間差 (秒)
func dt_sec () -> float :
	return self._delta_time_sec

## 設置 時間比例
func set_scale (time_scale, _user = null, _priority := 0) :
	if time_scale == null :
		if _user == null :
			self._time_scale_vals.set_default(1.0)
		else : 
			self._time_scale_vals.del_data(_user)
	else :
		if _user == null :
			self._time_scale_vals.set_default(time_scale)
		else : 
			self._time_scale_vals.set_data(_user, time_scale, _priority)

## 設置 是否暫停
func set_pause (is_pause, _user = null, _priority := 0) :
	if is_pause == null :
		if _user == null :
			self._is_pause_vals.set_default(false)
		else : 
			self._is_pause_vals.del_data(_user)
	else :
		if _user == null :
			self._is_pause_vals.set_default(is_pause)
		else : 
			self._is_pause_vals.set_data(_user, is_pause, _priority)

## 設置 是否在背景暫停
func set_pause_in_background (is_pause_in_background, _user, _priority = 0) :
	self._is_pause_in_background_vals.set_data(_user, is_pause_in_background, _priority)


# Private ====================

func _on_pause_update (ctrlr) :
	var is_paused : bool = self.is_paused()
		
	if self._last_is_paused == is_paused : return
	self._last_is_paused = is_paused
	
	if is_paused :
		self._delta_time = 0
		self._delta_time_sec = 0.0
		# 計算 最後時間 到 當前系統時間差距
		self._time_since_pause = self._get_sys_time() - self._last_time
	else :
		# 把 最後時間 反推回去
		self._last_time = self._get_sys_time() - self._time_since_pause
		
	self.on_pause_change.emit()
	

## 取得系統時間
func _get_sys_time () -> int :
	return Time.get_ticks_msec()
