extends Node

## PageCard.TargetPrefab_Node 頁面卡 目標預製物件 節點
## 
## 動態Dynamic : 
##   被呼叫card_active時, 會即時以Prefab建立實體到Container中.
##   被呼叫card_deactive時, 會將建立的實體釋放掉.
## 靜態Static : 
##   會在_ready時事先以Prefab建立實體.
##   被呼叫card_active時, 會將建立的實體開啟(visible與process_mode).
##   被呼叫card_deactive時, 會將建立的實體關閉(visible與process_mode).
## 被動Passtive :
##   類似Static, 但不會在_ready時就是先建立, 而使等到card_active時若不存在才建立實體.
## 

enum LifeMode {
	# 動態
	DYNAMIC,
	# 靜態
	STATIC,
	# 被動
	PASSTIVE,
}

# Variable ===================

## 容器
@export
var container : Node = null

@export
var life_mode : LifeMode = LifeMode.DYNAMIC :
	set (value) :
		var last : LifeMode = life_mode
		life_mode = value
		self._refresh_mode(last, life_mode)

## 預製物件
@export
var prefabs : Array[PackedScene] = []

## 已建立的
var _existed : Array[Node] = []

# GDScript ===================

func _ready () :
	if self.container == null :
		self.container = self
	
	match self.life_mode :
		LifeMode.STATIC :
			self._request_existed()

func _process (_dt) :
	pass

# Interface ==================

func card_active () :
	match self.life_mode :
		LifeMode.DYNAMIC :
			self._request_existed()
		LifeMode.STATIC :
			self._show_existed(true)
		LifeMode.PASSTIVE :
			self._request_existed()
			self._show_existed(true)
	

func card_deactive () :
	match self.life_mode :
		LifeMode.DYNAMIC :
			self._release_existed()
		LifeMode.STATIC :
			self._show_existed(false)
		LifeMode.PASSTIVE :
			self._show_existed(false)

# Public =====================

# Private ====================

func _request_existed () :
	if not self._existed.is_empty() : return
	for each in self.prefabs :
		var new_one : Node = each.instantiate()
		self._existed.push_back(new_one)
		self.container.add_child(new_one)

func _release_existed () :
	if self._existed.is_empty() : return
	for each in self._existed :
		each.queue_free()
	self._existed.clear()

func _show_existed (is_show := true) :
	for each in self._existed :
		if is_show :
			each.visible = true
			each.process_mode = Node.PROCESS_MODE_INHERIT
		else :
			each.visible = false
			each.process_mode = Node.PROCESS_MODE_DISABLED

func _refresh_mode (last_mode : int, next_mode : int) :
	if last_mode == next_mode : return
	match last_mode :
		LifeMode.DYNAMIC :
			self._release_existed()
	match next_mode :
		LifeMode.STATIC :
			self._request_existed()
