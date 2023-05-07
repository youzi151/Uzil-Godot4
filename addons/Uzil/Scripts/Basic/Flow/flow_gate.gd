
## Flow.gate 流程控制 條件
##
## 負責 不同的條件判定
## 

# Variable ===================

## 辨識
var _id := ""

## 核心
var _core = null

## 是否偵聽中
var _is_listening := false

## 是否已經滿足條件
var _is_complete := false

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
	
	if _memo.has("is_listening") :
		self._is_listening = _memo["is_listening"]
	
	if _memo.has("is_complete") :
		self._is_complete = _memo["is_complete"]
	
	self._load_memo(_memo)

## 匯出 紀錄
func to_memo (_memo = null, _args = null) :
	if _memo == null : _memo = {}
		
	_memo = self._to_memo(_memo, _args)
	
	_memo["is_listening"] = self._is_listening
	_memo["is_complete"] = self._is_complete
	
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
	self._is_listening = true
	self._on_enter()

## 每幀更新
func process (_dt) :
	self._on_process(_dt)

## 暫停
func pause () :
	self._is_listening = false
	self._on_pause()

## 恢復
func resume () :
	self._on_resume()
	self._is_listening = true

## 離開
func exit () :
	self._is_listening = false
	self._on_exit()

## 重設
func reset () :
	self._is_complete = false
	self._on_reset()

## 完成
func complete () :
	self._is_complete = true
	

## 是否已完成
func is_complete () -> bool :
	return self._is_complete

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

## 當 暫停
func _on_pause () :
	if self._core == null : return
	if self._core.has_method("_on_pause") == false : return
	self._core._on_pause()

## 當 恢復
func _on_resume () :
	if self._core == null : return
	if self._core.has_method("_on_resume") == false : return
	self._core._on_resume()

## 當 離開
func _on_exit () :
	if self._core == null : return
	if self._core.has_method("_on_exit") == false : return
	self._core._on_exit()

## 當 重設
func _on_reset () :
	if self._core == null : return
	if self._core.has_method("_on_reset") == false : return
	self._core._on_reset()

# Private ====================

## 取得所屬
func _get_inst () :
	if self._inst_cache == null :
		self._inst_cache = G.v.Uzil.flow.inst(self._inst_id)
	return _inst_cache
