extends Node

# desc ==========

## 索引 UTQ 標籤檢索
##
## 標籤檢索系統, tag可帶有negative, scope, attr屬性.[br]
## 可定義 如: %&/role:tank表示 角色定位 的 坦 tag, 並帶有 % 與 & 標記 供外部用途使用 [br]
## 可檢索 如: role:tank -element:fire,aqua 表示 搜尋 角色定位的坦 且 避免搜尋 火 水 屬性 [br]
## 

# Variable ===================

## 路徑
var SCRIPT_PATH : String = "res://addons/utq/scripts"

## 設定
var Cfg
## 標籤資料
var Tag

## 實體
var Inst
## 執行器
var Executor
## 查詢器
var Queryer

## 是否已經初始化
var _is_indexed := false
## 鍵 對 實例
var _key_to_inst := {}

# GDScript ===================

func _ready () :
	self.index()

# Public =====================

## 取得/建立 實例
func inst (key: String = "_") :
	if not self._is_indexed : self.index()
	if self._key_to_inst.has(key) :
		return self._key_to_inst[key]
	
	var inst = self.Inst.new.call(self)
	inst.cfg = self.Cfg.new.call()
	
	self._key_to_inst[key] = inst
	
	return inst

## 一次性的實例
func once (target_to_data := {}) :
	var inst = self.Inst.new.call(self)
	inst.cfg = self.Cfg.new.call()
	
	for target in target_to_data :
		var data : Dictionary = target_to_data[target]
		inst.set_data(target, data)
	
	return inst

## 新建標籤 包裝
func tag (...args) :
	return self.Tag.new.callv(args)

## 建立索引
func index () :
	if self._is_indexed : return
	
	var root_node : Node = self.get_tree().root
	if root_node.has_node("UREQ") :
		
		var UREQ = root_node.get_node("UREQ")
		
		# 綁定 索引
		UREQ.gbind(&"UTQ", func():
			self._utq_init()
			return self
		, {
			"alias" : [],
		})
		
	else :
		
		self._utq_init()
		
	
	self._is_indexed = true
	
	return self

func _utq_init () :
	if ProjectSettings.get_setting("uzil/extensions/utq_ext_enabled", false) :
		self.Inst = G.wrap_new(func(...args): return ClassDB.instantiate("UTQInst"))
		self.Tag = G.wrap_new(func(...args): return ClassDB.instantiate("UTQTag"))
		self.Cfg = G.wrap_new(func(...args): return ClassDB.instantiate("UTQCfg"))
		self.Executor = G.wrap_new(func(...args): return ClassDB.instantiate("UTQExecutor"))
		self.Queryer = G.wrap_new(func(...args): return ClassDB.instantiate("UTQQueryer"))
	else :
		self.Inst = G.load_script(self.SCRIPT_PATH.path_join("utq_inst.gd"))
		self.Tag = G.load_script(self.SCRIPT_PATH.path_join("utq_tag.gd"))
		self.Cfg = G.load_script(self.SCRIPT_PATH.path_join("utq_cfg.gd"))
		self.Executor = G.load_script(self.SCRIPT_PATH.path_join("utq_executor.gd"))
		self.Queryer = G.load_script(self.SCRIPT_PATH.path_join("utq_queryer.gd"))
