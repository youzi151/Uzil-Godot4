extends Node

## Uzil工具集
##
## 
##

## 根路徑
const ROOT_PATH := "res://addons/Uzil"

## 版本
const VERSION := "0.1.0"

## 腳本路徑
const PATH := ROOT_PATH + "/Scripts"

# Variable ===================

## 是否已經建立索引
var _is_indexed := false

## 是否已經讀取完畢
var _is_loaded := false

## 是否已經準備完畢
var _is_ready := false

## 是否已經初始化
var _is_init := false

# 類別 index

## 常數
var Const = null

## 公用
var Util

## 核心
var Core

## 基本
var Basic

## 進階
var Advance

## 子索引
var sub_indexes := []

# 宣告 便於 外部使用 的 模塊中類別

## 時間 管理
var times
## 呼叫器 管理
var invoker
## 事件 管理
var evtbus
## 變數庫
var vars

## 流程
var flow
## 用戶存檔
var user_save
## 輸入管道
var input_pipe
## 在地化
var i18n
## 標籤檢索
var tag_search

## 狀態機
var states
## 音效
var audio

## 當 建立索引後
var _once_indexed := []
## 當 讀取後
var _once_loaded := []
## 當 初始化後
var _once_init := []
## 當 完成準備後
var _once_ready := []

## 當 推進
var on_process = null
## 當 通知
var on_notification = null
## 當 輸入
var on_input = null

# GDScript ===================

func _init () :
	print("Uzil version:%s _init()" % self.VERSION)
	
	# 移除先前的
	if G.v.has("Uzil") :
		if is_instance_valid(G.v.Uzil) :
			var uzil_node : Node = G.v.Uzil
			uzil_node.get_parent().remove_child(uzil_node)
			uzil_node.free()
	
	# 設置 為 全域G變數 Uzil
	G.set_global("Uzil", self)
	
	# 變更 執行模式 為 持續
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 此處不呼叫初始化或重新讀取 因為在Uzil尚未完全建立前 init底下的其他script會無法引用到Uzil

# Called when the node enters the scene tree for the first time.
func _ready () :
	# 呼叫 當 準備完畢
	self._call_once_ready()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	if not self._is_init : return
	self.on_process.emit({"dt":_dt})

func _input (evt) :
	if not self._is_init : return
	self.on_input.emit({"event":evt})

func _notification (what) : 
	if not self._is_init : return
	self.on_notification.emit({"what":what})

# Public =====================

## 初始化 (建立索引 並 重新讀取)
func init () :
	self._is_init = false
	
	# 建立索引
	self.index()
	
	# 重新讀取
	self.reload()
	
	# 呼叫 當 初始化完畢
	self._call_once_init()
	
	print("Uzil Inited!")

## 建立索引
func index () :
	self._is_indexed = false
	
	# Util ####
	self.Util = self.load_script(self.PATH.path_join("Util/index_util.gd")).new()
	self.sub_indexes.push_back(self.Util)
	
	# Core ####
	self.Core = self.load_script(self.PATH.path_join("Core/index_core.gd")).new()
	self.sub_indexes.push_back(self.Core)
	
	# Basic ####
	self.Basic = self.load_script(self.PATH.path_join("Basic/index_basic.gd")).new()
	self.sub_indexes.push_back(self.Basic)
	
	# Advance ####
	self.Advance = self.load_script(self.PATH.path_join("Advance/index_advance.gd")).new()
	self.sub_indexes.push_back(self.Advance)
	
	# DI綁定
	UREQ.gbind("Uzil", self)
	UREQ.bind("Uzil", "Uzil", self)
	
	# 建立索引
	for each in self.sub_indexes :
		each.index(self, self)
	
	# 呼叫 當 建立索引完畢
	self._call_once_indexed()


## 重新讀取
func reload () :
	self._is_loaded = false
	
	var Evt = UREQ.acc("Uzil", "Core.Evt")
	
	self.on_process = Evt.Inst.new()
	self.on_notification = Evt.Inst.new()
	self.on_input = Evt.Inst.new()
	
	# 呼叫 當 讀取完畢
	self._call_once_loaded()

## 註冊 當 建立索引
func once_indexed (callable) :
	if self._is_indexed :
		callable.call()
		return
		
	if self._once_indexed.has(callable) == false :
		self._once_indexed.push_back(callable)

## 呼叫 當 建立索引
func _call_once_indexed () :
	if self._is_indexed : return
	
	self._is_indexed = true
	
	for each in self._once_indexed :
		each.call()
	self._once_indexed.clear()

## 註冊 當 讀取完畢
func once_loaded (callable) :
	if self._is_loaded :
		callable.call()
		return
		
	if self._once_loaded.has(callable) == false :
		self._once_loaded.push_back(callable)

## 呼叫 當 讀取完畢
func _call_once_loaded () :
	if self._is_loaded : return
	
	self._is_loaded = true
	
	for each in self._once_loaded :
		each.call()
	self._once_loaded.clear()

## 註冊 當 初始化完畢
func once_init (callable) :
	if self._is_init :
		callable.call()
		return
		
	if self._once_init.has(callable) == false :
		self._once_init.push_back(callable)

## 呼叫 當 初始化完畢
func _call_once_init () :
	if self._is_init : return
	
	self._is_init = true
	
	for each in self._once_init :
		each.call()
	self._once_init.clear()


## 註冊 當 準備完畢
func once_ready (callable) :
	if self._is_ready :
		callable.call()
		return
		
	if self._once_ready.has(callable) == false :
		self._once_ready.push_back(callable)

## 呼叫 當 準備完畢
func _call_once_ready () :
	if self._is_ready : return
	
	self._is_ready = true
	
	for each in self._once_ready :
		each.call()
	self._once_ready.clear()

## 讀取腳本
func load_script (path, is_force_reload := false) :
	if not is_force_reload and ResourceLoader.has_cached(path) :
		return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	else :
		return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
