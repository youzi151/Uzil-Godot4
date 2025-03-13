
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

## 初始化設置
func setup (runtime, transition) :
	pass

## 推進
func process (runtime, transition) :
	pass

## 開始
func start (runtime, transition) :
	var wait_ms : int = 0
	if transition.data.has("wait_sec"):
		wait_ms = int(transition.data["wait_sec"] * 1000)
	
	if wait_ms > 0 :
		await UREQ.acc(&"Uzil:invoker").wait(wait_ms)


# Public =====================

# Private ====================
