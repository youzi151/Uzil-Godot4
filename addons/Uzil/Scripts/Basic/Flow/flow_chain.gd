
## Flow.chain 流程控制 節點鏈
##
## 與其他 節點 相互串接
## 

var Flow

# Variable ===================

## 辨識
var _id : String = ""

## 狀態
var _state : int = 0

## 核心
var _core = null

## 後續節點
var next_chains : Array = []

## 所屬
var _inst_id : String = ""
var _inst_cache = null

# GDScript ===================

func _init (core) :
	self.Flow = UREQ.access_g("Uzil", "Basic.Flow")
	
	self._state = self.Flow.ActiveState.INACTIVE
	self._core = core
	if core.has_method("_set_shell") == false : return
	core._set_shell(self)

# Interface ==================

## 讀取 紀錄
func load_memo (_memo) :
	
	if _memo.has("state") :
		self._state = _memo["state"]
	
	if _memo.has("next_chains") :
		self.next_chains = _memo["next_chains"]
	
	self._load_memo(_memo)

## 匯出 紀錄
func to_memo (_memo = null, _args = null) :
	if _memo == null : _memo = {}
	
	_memo = self._to_memo(_memo, _args)
	
	_memo["state"] = self._state
	_memo["next_chains"] = self.next_chains.duplicate()
	
	return _memo

# Public =====================

## 初始化
func init (inst_id : String, init_data : Dictionary) :
	self._inst_cache = null
	self._inst_id = inst_id
	
	if init_data.has("id") :
		self._id = init_data["id"]
	
	if init_data.has("next_chains") :
		self.next_chains = init_data["next_chains"]
	
	self._on_init(init_data)
	

## 每幀更新
func process (_dt) :
	self._on_process(_dt)

## 銷毀
func destroy () :
	self._on_destroy()

## 取得ID
func id () -> String :
	return self._id

## 進入
func enter () :
	self._state = self.Flow.ActiveState.ACTIVE
	self._on_enter()
	

## 離開
func exit () :
	self._state = self.Flow.ActiveState.INACTIVE
	self._on_exit()
	

## 新增 後續節點
func add_next (chain_id : String) :
	self.next_chains.push_back(chain_id)
	

## 移除 後續節點
func del_next (chain_id : String) :
	self.next_chains.erase(chain_id)

## 取得 後續節點
func get_nexts () -> Array :
	return self.next_chains

# Extends ====================

## 當 初始化 
func _on_init (_args) :
	if self._core == null : return
	if self._core.has_method("_on_init") == false : return
	self._core._on_init(_args)

## 當 銷毀 
func _on_destroy () :
	if self._core == null : return
	if self._core.has_method("_on_destroy") == false : return
	self._core._on_destroy()

## 讀取 紀錄
func _load_memo (_memo) :
	if self._core == null : return
	if self._core.has_method("_load_memo") == false : return
	self._core._load_memo(_memo)

## 匯出 紀錄
func _to_memo (_memo, _args) :
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
		var flow = UREQ.access_g("Uzil", "flow_mgr")
		self._inst_cache = flow.inst(self._inst_id)
	return self._inst_cache
