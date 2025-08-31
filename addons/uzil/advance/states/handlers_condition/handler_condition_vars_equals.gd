
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

## 初始化設置
func setup (runtime, condition) :
	pass

## 推進
func process (runtime, condition) :
	pass

## 是否通過
func is_pass (runtime, transition, condition) :
	if condition.data.has("vars_equals") :
		var vars = runtime.vars()
		var key_to_val : Dictionary = condition.data["vars_equals"]
		for key in key_to_val :
			if not vars.has_var(key) : return false
			if vars.get_var(key) != key_to_val[key] : return false
		return true
	
	return false

# Public =====================

# Private ====================
