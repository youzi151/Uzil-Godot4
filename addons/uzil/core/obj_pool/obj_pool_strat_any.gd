
## ObjPool.Strat_Any物件池 策略 任意物件
##
## 可供 物件池 核心 所使用的策略[br]
## 用來建立存取任意物件
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

## 建立 方法
var _create_fn : Callable

## 銷毀 方法
var _destroy_fn : Callable

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
	if data.has("init") :
		self.set_init(data["init"])
	if data.has("uninit") :
		self.set_uninit(data["uninit"])
	if data.has("create") :
		self.set_create(data["create"])
	if data.has("destroy") :
		self.set_destroy(data["destroy"])
	return self

## 建立
func create () :
	if self._create_fn.is_null() : return null
	return self._create_fn.call()

## 銷毀
func destroy (target) :
	if self._destroy_fn.is_null() : return
	self._destroy_fn.call(target)

## 初始化
func initial (new_one, _data) :
	if self._init_fn.is_null() : return new_one
	return self._init_fn.call(new_one, _data)

## 反初始化
func uninitial (old_one) :
	if self._uninit_fn.is_null() : return old_one
	return self._uninit_fn.call(old_one)

# Public =====================

## 設置 建立
func set_create (create_fn: Callable) :
	self._create_fn = create_fn
	return self

## 設置 銷毀
func set_destroy (destroy_fn: Callable) :
	self._destroy_fn = destroy_fn
	return self

## 設置 初始化
func set_init (initial_fn: Callable) :
	self._init_fn = initial_fn
	return self

## 設置 反初始化
func set_uninit (uninitial_fn: Callable) :
	self._uninit_fn = uninitial_fn
	return self
