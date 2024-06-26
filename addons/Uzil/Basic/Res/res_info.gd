
## Uzil.Basic.Res.Info 資源資訊
##
## 存有 資源引用, 持有者 以及 其他操作資源管理所需 的 相關資訊.
##

# Variable ===================

## 識別
var id : String = ""

## 資源
var res = null

## 持有者
var holders : Dictionary = {}

## 當 釋放
var on_drop : Array = []

## 其他資料
var data : Dictionary = {}

# GDScript ===================

func _init (res) :
	self.res = res

# Extends ====================

# Interface ==================

# Public =====================

## 持有
func hold (holder) :
	if self.holders.has(holder) : return
	self.holders[holder] = true

## 釋放
func drop (holder) :
	if not self.holders.has(holder) : return
	# 釋放 對應持有者
	self.holders.erase(holder)
	
	# 呼叫 事件
	for each in self.on_drop :
		each.call()
	
	# 依照 是否 資源還存活 回傳
	if not self.is_alive() :
		return null
	else :
		return self

## 釋放 所有
func drop_all () :
	# 清空 持有者
	self.holders.clear()
	
	# 呼叫 事件
	for each in self.on_drop :
		each.call()
	
	# 依照 是否 資源還存活 回傳
	if not self.is_alive() :
		return null
	else :
		return self

## 是否存活
func is_alive () :
	# 若 仍有 持有者 則 存活
	if self.is_hold() : return true
	# 若 資源引用計數 (除了被這裡引用以外) 還存在 則 存活
	if self.res is RefCounted :
		if self.res.get_reference_count() > 1 : return true
	
	# 皆未通過 則 不存活
	return false

## 是否被持有
func is_hold (holder = null) :
	if holder == null :
		return self.holders.size() > 0
	else :
		return self.holders.has(holder)

# Private ====================
