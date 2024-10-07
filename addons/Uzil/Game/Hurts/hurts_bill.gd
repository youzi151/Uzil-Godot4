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
## 數值 (負數為傷害 正數為治療)
var val : float = 0.0
## 剩餘量
var remain : float = 0.0
## 已造成傷害 str:float
var hurteds : Dictionary = {}


## 資料
var args : Dictionary = {}

# GDScript ===================

func _init (_hurts_inst) :
	self.hurts_inst = _hurts_inst

func _to_string() -> String :
	var dict : Dictionary = {
		"id": self.id,
		"src": self.src,
		"dst": self.dst,
		"val": self.val,
		"remain": self.remain,
		"hurteds": self.hurteds,
	}
	dict.merge(self.args, true)
	return str(dict)

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
	if data.has("hurteds") :
		self.hurteds = data["hurteds"].duplicate(true)
	self.args = data.duplicate(true)

## 組成資料
func build_data () -> Dictionary : 
	var dict := {
		"bill": self,
		"id": self.id,
		"src": self.src.duplicate(true),
		"dst": self.dst.duplicate(true),
		"val": self.val,
		"remain": self.remain,
	}
	dict.merge(self.args, true)
	return dict

## 保持
func retain (_remain: float = -1.0) :
	self.remain = _remain
	return self

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
		self.done()

## 完成
func done () :
	self.hurts_inst.done_bill(self)

## 是否傷害過
func is_hurted (key: String) :
	return self.hurteds.has(key)

## 傷害量
func get_hurted (key: String) :
	if self.hurteds.has(key) : return self.hurteds[key]
	else : return 0.0

## 傷害過
func hurted (key: String, hurted_val: float = 0.0) :
	if self.hurteds.has(key) :
		self.hurteds[key] += hurted_val
	else :
		self.hurteds[key] = hurted_val

## 取得 副本
func duplicate () :
	var new_one = self.get_script().new(self.hurts_inst)
	new_one.id = self.id
	new_one.is_done = self.is_done
	new_one.src = self.src.duplicate(true)
	new_one.dst = self.dst.duplicate(true)
	new_one.val = self.val
	new_one.hurteds = self.hurteds.duplicate(true)
	new_one.args = self.args.duplicate(true)
	return new_one

# Private ====================
