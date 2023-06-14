
## ObjPool.Core_Any物件池 核心 任意物件
##
## 可供 物件池 殼 所使用的核心[br]
## 用來建立存取任意物件
##

# Static =====================

## 建立 新的 殼
static func new_shell () :
	var ObjPool = UREQ.access_g("Uzil", "Core.ObjPool")
	var __shell = ObjPool.Shell.new()
	var _core = new().set_shell(__shell)
	return __shell

# Variable ===================

## 殼
var _shell

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

## 建立
func create () :
	return self._create_fn.call()

## 銷毀
func destroy (target) :
	self._destroy_fn.call(target)

## 初始化
func initial (new_one) :
	return self._init_fn.call(new_one)

## 反初始化
func uninitial (old_one) :
	return self._uninit_fn.call(old_one)

# Public =====================

## 建立殼並回傳
func set_shell (__shell) :
	self._shell = __shell
	self._shell.set_core(self)
	return self

## 設置 建立
func set_create (create_fn : Callable) :
	self._create_fn = create_fn
	return self

## 設置 銷毀
func set_destroy (destroy_fn : Callable) :
	self._destroy_fn = destroy_fn
	return self

## 設置 初始化
func set_init (initial_fn : Callable) :
	self._init_fn = initial_fn
	return self

## 設置 反初始化
func set_uninit (uninitial_fn : Callable) :
	self._uninit_fn = uninitial_fn
	return self
