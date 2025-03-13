extends Object

# Variable ===================

## 辨識
var id : String = ""

## 策略
var handlers : Array = []

## 下一個狀態
var to_state : String = ""

## 條件
var condition_exp : Expression = null

## 條件
var conditions : Array = []

## 資料
var data : Dictionary = {}

# GDScript ===================

# Extends ====================

# Public =====================

func set_dict (dict: Dictionary) :
	self.to_state = dict["to_state"]
	if dict.has("handlers") :
		self.handlers = dict["handlers"]
	if dict.has("conditions") :
		self.conditions = dict["conditions"]
	if dict.has("condition_exp") :
		var exp = dict["condition_exp"]
		match typeof(exp) :
			TYPE_STRING :
				var expression := Expression.new()
				if expression.parse(exp, ["runtime", "vars", "state_data"]) != OK:
					G.print(self.condition_exp.get_error_text())
				else :
					self.condition_exp = expression
			_ :
				self.condition_exp = exp
	if dict.has("data") :
		self.data = dict["data"]

# Private ====================
