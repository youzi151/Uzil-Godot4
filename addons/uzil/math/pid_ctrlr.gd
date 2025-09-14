extends RefCounted

# Variable ===================

## PID 參數

## 比例增益 : 根據當前誤差大小產生控制信號 (建議: 0.1 ~ 10.0)
## 過低：響應太慢無法有效追蹤目標 / 低值：響應緩慢 穩定 / 高值：響應快 易產生震盪和超調 / 過高：不穩定持續震盪
var kp : float = 1.0  

## 積分增益 : 消除穩態誤差，累積歷史誤差 (建議: 0.0 ~ 2.0)
## 0: 無法消除穩態誤差 / 低值：穩態誤差 消除慢 / 高值：能快速消除穩態誤差 但可能導致超調 / 過高：不穩定產生震盪
var ki : float = 0.5

## 微分增益 : 預測未來誤差趨勢，提供阻尼效果 (建議: 0.0 ~ 1.0)
## 低值：阻尼效果弱 / 高值：減少超調 提高穩定性 對噪音敏感 / 過高：對噪音過敏 可能不穩定
var kd : float = 0.8

## 內部狀態
var _previous_error : float = 0.0
var _integral : float = 0.0

## 積分限制
var _integral_limit : float = 50.0

# GDScript ===================

func _init (p := 1.0, i := 0.5, d := 0.8) :
	self.set_parameters(p, i, d)

# Extends ====================

# Interface ==================

# Public =====================

## 計算 PID 輸出
func calculate (setpoint: float, current_value: float, dt: float) -> float :
	
	# 避免除零錯誤
	if dt <= 0.0 : return current_value
	
	var error : float = setpoint - current_value
	
	# 比例項
	var proportional : float = self.kp * error
	
	# 積分項
	self._integral += error * dt
	# 限制積分項防止積分飽和
	self._integral = clamp(self._integral, -self._integral_limit, self._integral_limit)
	var integral : float = self.ki * self._integral
	
	# 微分項
	var derivative : float = self.kd * (error - self._previous_error) / dt
	
	# 更新狀態
	self._previous_error = error
	
	# 計算總輸出
	var output : float = proportional + integral + derivative
	
	return output

## 重置控制器狀態
func reset():
	self._previous_error = 0.0
	self._integral = 0.0

## 設置積分限制
func set_integral_limit (limit: float) :
	self._integral_limit = abs(limit)

## 設置 PID 參數
func set_parameters (p: float, i: float, d: float) :
	self.kp = p
	self.ki = i
	self.kd = d

# Private ====================
