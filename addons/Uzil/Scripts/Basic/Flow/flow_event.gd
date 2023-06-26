
## Flow.event 流程控制 事件
##
## 負責 不同的執行內容
## 

# Variable ===================

## 辨識
var _id := ""

## 核心
var _core = null

## 資料
var data := {}

## 是否完成 (用於一些特殊需要判斷是否執行完畢的狀況)
var _is_done := false

## 所屬的 流程控制 實體
var _inst_id = null
var _inst_cache = null

# GDScript ===================

func _init (core) :
	self._core = core
	if core.has_method("_set_shell") == false : return
	core._set_shell(self)

# Interface ==================

## 讀取 紀錄
func load_memo (_memo : Dictionary) :
	
	if _memo.has("is_done") :
		self._is_done = _memo["is_done"]
	
	if _memo.has("data") :
		self.data = _memo["data"]
	
	self._load_memo(_memo)

## 匯出 紀錄
func to_memo (_memo : Dictionary, _args = null) :
	_memo = self._to_memo(_memo, _args)
	
	_memo["is_done"] = self._is_done
	_memo["data"] = self.data.duplicate()
	
	return _memo

# Public =====================

## 初始化
func init (inst_id : String, init_data : Dictionary) :
	self._inst_cache = null
	self._inst_id = inst_id
	
	if init_data.has("id") :
		self._id = init_data["id"]
	
	self._on_init(init_data)

## 取得ID
func id () -> String :
	return self._id

## 進入
func enter () :
	self._on_enter()
	

## 每幀更新
func process (_dt) :
	self._on_process(_dt)

## 離開
func exit () :
	self._on_exit()

## 標示為執行完畢
func done (__is_done = true) :
	self._is_done = __is_done

## 是否執行完畢
func is_done () -> bool :
	return self._is_done

# Extends ====================

## 當 初始化 
func _on_init (_init_data) :
	if self._core == null : return
	if self._core.has_method("_on_init") == false : return
	self._core._on_init(_init_data)

## 讀取 紀錄
func _load_memo (_memo : Dictionary) :
	if self._core == null : return
	if self._core.has_method("_load_memo") == false : return
	self._core._load_memo(_memo)

## 匯出 紀錄
func _to_memo (_memo : Dictionary, _args) :
	if self._core == null : return {}
	if self._core.has_method("_to_memo") == false : return {}
	return self._core._to_memo(_memo, _args)

## 當 進入
func _on_enter () :
	if self._core == null : return
	if self._core.has_method("_on_enter") == false : return
	self._core._on_enter()

## 當 每幀更新
func _on_process (_dt) :
	if self._core == null : return
	if self._core.has_method("_on_process") == false : return
	self._core._on_process(_dt)

## 當 離開
func _on_exit () :
	if self._core == null : return
	if self._core.has_method("_on_exit") == false : return
	self._core._on_exit()

# Private ====================

## 取得所屬
func _get_inst () :
	if self._inst_cache == null :
		var flow = UREQ.acc("Uzil", "flow_mgr")
		self._inst_cache = flow.inst(self._inst_id)
	return self._inst_cache
