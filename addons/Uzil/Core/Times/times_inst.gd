extends Node

## Times 時間 實體
##
## 代表一個時間軸的時間實體, 可暫停/恢復計時.
##

# Variable ===================

## 是否 在背景執行時計時 (失去焦點時不暫停) 多重數值
var _is_timing_in_background_vals = null

## 是否計時中 多重數值
var _is_timing_vals = null

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

## 暫停後多出來的時間
var _time_since_pause := 0

## 是否為自動暫停 (也要自動復原)
var _is_auto_pause := false

# Extends ====================

# GDScript ===================

func _init (_dont_set_in_scene) :
	var Vals = UREQ.acc("Uzil", "Core.Vals")
	var Times = UREQ.acc("Uzil", "Core.Times")
	
	self._is_timing_in_background_vals = Vals.new()
	self._is_timing_vals = Vals.new()
	self._time_scale_vals = Vals.new()
	
	self._start_time = self._get_sys_time()
	self._last_time = self._start_time
	
	self._is_timing_in_background_vals.set_default(false)
	self._is_timing_vals.set_default(true)
	self._time_scale_vals.set_default(1.0)
	
	self._is_timing_in_background_vals.set_data(
		"CONFIG",
		func(): return Times.is_timing_in_background_config,
		Times.Priority.CONFIG
	)

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_delta) :
	pass

func _notification (msg) :
	# 若在 背景中計時 則 忽略
	if self._is_timing_in_background_vals.current() : return
	
	match msg :
		# 進入焦點
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN : 
			self._resume(true)
		# 離開焦點
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT : 
			self._pause(true)
		
# Public =====================

## 推進
func process (_dt) :
	if self._is_timing_vals.current() == false : return
	var sys_time = self._get_sys_time()
	self._delta_time = (sys_time - self._last_time) * self._time_scale_vals.current()
	self._delta_time_sec = float(self._delta_time) * 0.001
	self._last_time = sys_time
	self._time = self._time + self._delta_time

## 是否計時中
func is_timing () :
	return self._is_timing_vals.current()

## 取得 當前時間 (豪秒)
func now () :
	return self._time

## 取得 該幀時間差 (豪秒)
func dt () -> int :
	return self._delta_time

## 取得 該幀時間差 (秒)
func dt_sec () -> float :
	return self._delta_time_sec

## 設置 在背景計時
func set_timing_in_background (is_timing_in_background, _user, _priority = 0) :
	self._is_timing_in_background_vals.set_data(_user, is_timing_in_background, _priority)

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

## 繼續
func resume () :
	self._resume(false)

## 暫停
func pause () :
	self._pause(false)


# Private ====================


## 繼續
func _resume (is_auto_pause : bool) :
	var is_timing_last : bool = self._is_timing_vals.current()
	#print("resume")
	#print(self._is_timing_vals.current())
	#print(self._is_timing_vals._current_data)
	if is_auto_pause : 
		self._is_timing_vals.del_data("_auto")
		self._is_auto_pause = false
	else : 
		self._is_timing_vals.set_default(true)
	
	if is_timing_last == false :
		self._last_time = self._get_sys_time() - self._time_since_pause
		
	
	#print(self._is_timing_vals.current())
		

## 暫停
func _pause (is_auto_pause : bool) :
	var is_timing_last : bool = self._is_timing_vals.current()
	
	self._is_auto_pause = is_auto_pause
	self._delta_time = 0
	
	if is_auto_pause : 
		self._is_timing_vals.set_data("_auto", false, 1)
	else : 
		self._is_timing_vals.set_default(false)
		
	self._time_since_pause = self._get_sys_time() - self._last_time
	
	if is_timing_last == true :
		self._time_since_pause = self._get_sys_time() - self._last_time

## 取得系統時間
func _get_sys_time () -> int :
	return Time.get_ticks_msec()
