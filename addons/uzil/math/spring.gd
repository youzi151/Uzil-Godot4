extends RefCounted

## 基準值
var target_value: float = 0.0
## 當前值
var current_value: float = 0.0
## 彈簧強度 (值越大，回彈越快)
var spring_strength: float = 10.0
## 阻尼係數 (值越大，振盪衰減越快)
var damping: float = 0.05
## 速度
var velocity: float = 0.0
## 質量
var mass: float = 0.01
## 最大
var max_value: float = INF
## 最小
var min_value: float = INF

## 推進
func process (_dt) :
	# 計算與目標值的差距
	var displacement = self.target_value - self.current_value
	
	# 計算彈簧力 (胡克定律)
	var spring_force = displacement * self.spring_strength
	
	# 應用阻尼和力
	self.velocity = self.velocity * (1.0 - self.damping) + (spring_force / self.mass) * _dt
	
	# 更新當前值
	self.current_value += self.velocity * _dt
	if not is_inf(max_value) and self.current_value > self.max_value :
		self.current_value = self.max_value 
		self.velocity = 0.0
	elif not is_inf(min_value) and self.current_value < self.min_value :
		self.current_value =self.min_value 
		self.velocity = 0.0

## 單次施力
func apply_impulse(force: float):
	# 考慮質量的衝量
	self.velocity += force / self.mass

## 持續施力
func apply_force(force: float, delta: float):
	# 先轉換為加速度，再影響速度
	self.velocity += (force / self.mass) * delta
