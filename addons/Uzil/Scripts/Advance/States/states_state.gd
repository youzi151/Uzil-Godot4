extends Node

# Variable ===================

## 辨識
var id : String = ""

## 核心
var _core = null

## 是否已初始化
var _is_inited := false

## 是否啟用
var _is_active := false

# GDScript ===================

func _init (_core_or_script_id) :
	
	var States = UREQ.acc("Uzil", "Advance.States")
	
	# 若 為 id字串
	if typeof(_core_or_script_id) == TYPE_STRING :
		# 試著取得並建立腳本
		var script = States.get_state_script(_core_or_script_id)
		if script != null :
			self._core = script.new()
	# 若 為 核心
	else :
		self._core = _core_or_script_id
	
	# 若 核心存在
	if self._core != null :
		# 試 設置 所屬狀態
		if self._core.has_method("set_state") :
			self._core.set_state(self)

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	pass

# Extends ====================

# Public =====================

## 初始化
func init (data = null) :
	if self._is_inited : return
	if self._core == null : return
	
	# 初始化 核心
	if self._core.has_method("init") : 
		self._core.init(data)
	
	# 若 資料存在 則 設置資料
	if data != null :
		self.set_data(data)
		
	self._is_inited = true

## 更新
func process (_dt) :
	# 未啟用 則 返回
	if not self._is_active : return
	
	# 試 呼叫 更新
	if self._core != null :
		if self._core.has_method("process") :
			self._core.process(_dt)

## 設置 ID
func set_id (_id : String) :
	self.id = _id
	return self

## 設置 使用主體
func set_user (user) :
	if self._core == null : return self
	
	if self._core.has_method("set_user") : 
		self._core.set_user(user)
	return self

## 設置 資料
func set_data (data) :
	if self._core == null : return self
	
	if self._core.has_method("set_data") : 
		self._core.set_data(data)
	return self

## 當 狀態 進入
func on_enter () :
	# 設置 啟用
	self._is_active = true
	# 試 呼叫 當進入
	if self._core == null : return
	if self._core.has_method("on_enter") : 
		self._core.on_enter()

## 當 狀態 離開
func on_exit () :
	# 設置 非啟用
	self._is_active = false
	# 試 呼叫 當離開
	if self._core == null : return
	if self._core.has_method("on_exit") : 
		self._core.on_exit()

# Private ====================

