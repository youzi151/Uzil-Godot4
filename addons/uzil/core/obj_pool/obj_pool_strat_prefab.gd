
## ObjPool.Strat_Prefab物件池 策略 預製物件
##
## 可供 物件池 核心 所使用的策略[br]
## 用來建立存取Prefab(PackedScene)
##

# Static =====================

## 以 此策略 建立 核心
static func new_core () :
	var ObjPool = UREQ.acc(&"Uzil:Core.ObjPool")
	var __core = ObjPool.Core.new()
	var _strat = new().set_core(__core)
	return __core

# Variable ===================

## 核心
var _core

## 預製物件
var _prefab : PackedScene

## 等候容器
## 會使物件被建立後先設置為此容器之子節點, 以利初始化. 並且於反初始化後回歸容器. [br]
## 但在高密集呼叫時, 反覆進行子節點關係設置容易造成效能問題.
var _stay_parent : Node

## 建立 方法
var _created_fn : Callable

## 初始化 方法
var _init_fn : Callable

## 反初始化 方法
var _uninit_fn : Callable

# GDScript ===================

# Interface ==================

## 建立核心並回傳
func set_core (__core) :
	self._core = __core
	self._core.set_strat(self)
	return self

## 設置 資料
func set_data (data: Dictionary) :
	if data.has("prefab") :
		self.set_prefab(data["prefab"])
	if data.has("stay_parent") :
		self.set_stay_parent(data["stay_parent"])
	if data.has("created") :
		self.set_created(data["created"])
	if data.has("init") :
		self.set_init(data["init"])
	if data.has("uninit") :
		self.set_uninit(data["uninit"])
	return self

## 建立
func create () :
	if self._prefab == null : return null
	var inst : Node = self._prefab.instantiate()
	if not self._created_fn.is_null() :
		self._created_fn.call(inst)
	return inst

## 銷毀
func destroy (target) :
	target.queue_free()

## 初始化
func initial (new_one, _data) :
	if self._stay_parent != null and new_one.get_parent() == null :
		self._stay_parent.add_child(new_one)
	
	var res = new_one
	if not self._init_fn.is_null() : 
		res = self._init_fn.call(new_one, _data)
	return res

## 反初始化
func uninitial (old_one) :
	var res = old_one
	
	if not self._uninit_fn.is_null() : 
		res = self._uninit_fn.call(old_one)
	
	# 若有 上層節點 與 收管節點 且 上層節點 不是 收管節點
	var parent : Node = old_one.get_parent()
	if parent != null and self._stay_parent != null and parent != self._stay_parent :
		# 重設 上層節點 為 收管節點
		if old_one.is_inside_tree() :
			old_one.reparent.call_deferred(self._stay_parent, false)
		else :
			parent.remove_child(old_one)
			self._stay_parent.add_child(old_one)
	
	return res

# Public =====================

## 設置 預製物件
func set_prefab (prefab: PackedScene) :
	self._prefab = prefab
	return self

## 設置 等候容器
func set_stay_parent (node: Node) :
	self._stay_parent = node

## 設置 建立
func set_created (created_fn: Callable) :
	self._created_fn = created_fn
	return self

## 設置 初始化
func set_init (initial_fn: Callable) :
	self._init_fn = initial_fn
	return self

## 設置 反初始化
func set_uninit (uninitial_fn: Callable) :
	self._uninit_fn = uninitial_fn
	return self
