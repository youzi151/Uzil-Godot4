
# Variable ===================

## 值
var val = null

## 總結值
var summary_val = null

## 是否影響 上層資料
var is_effect_parent := true

## 上層資料
var parent_data = null

## 子資料
var sub_datas := []

## 路由
var route : String = ""

## 當 刷新
var on_update = null

# GDScript ===================

func _init () :
	self.on_update = G.v.Uzil.Core.Evt.Inst.new()

# Extends ====================

# Public =====================

## 清空
func clear () :
	self.val = null
	self.summary_val = null
	self.sub_datas.clear()
	
	self.route = ""
	self.parent_data = null
	self.on_update.clear()

# Private ====================

