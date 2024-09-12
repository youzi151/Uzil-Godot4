# Variable ===================

## 所屬傷害器
var hurts_inst : RefCounted

## 辨識
var id : int

## 是否完成
var is_done : bool = false

## 來源
var src : Array = []
## 目標列表
var dst : Array = []
## 數值
var val : float = 0.0
## 剩餘量
var remain : float = 0.0
## 已造成傷害
var hurted : float = 0.0


## 資料
var args : Dictionary = {}

# GDScript ===================

func _init (_hurts_inst) :
	self.hurts_inst = _hurts_inst

func _to_string() -> String :
	return str(self.export())

# Extends ====================

# Interface ==================

# Public =====================

## 設置資料
func set_data (data: Dictionary) :
	data = data.duplicate()
	if data.has("src") :
		self.src = data["src"].duplicate(true)
		data.erase("src")
	if data.has("dst") :
		self.dst = data["dst"].duplicate(true)
		data.erase("dst")
	if data.has("val") :
		self.val = data["val"]
		data.erase("val")
	if data.has("remain") :
		self.remain = data["remain"]
		data.erase("remain")
	self.args = data.duplicate(true)

## 匯出資料
func export () -> Dictionary : 
	var base_dict := {
		"id": self.id,
		"src": self.src.duplicate(true),
		"dst": self.dst.duplicate(true),
		"val": self.val,
		"remain": self.remain,
		"hurted": self.hurted,
	}
	base_dict.merge(self.args, true)
	return base_dict

## 取得參數
func get_arg (key: String, default_val = null) :
	if self.args.has(key) == false : return default_val
	return self.args[key]

## 消耗
func cost (_cost: float = 0.0) :
	if self.remain < 0.0 : return
	
	if _cost < 0.0 :
		self.remain = 0.0
	else :
		self.remain -= _cost
	
	if self.remain <= 0.0 :
		self.hurts_inst.done_bill(self)

## 取得 副本
func duplicate () :
	var new_one = self.get_script().new(self.hurts_inst)
	new_one.id = self.id
	new_one.is_done = self.is_done
	new_one.src = self.src.duplicate(true)
	new_one.dst = self.dst.duplicate(true)
	new_one.val = self.val
	new_one.args = self.args.duplicate(true)
	return new_one

# Private ====================
