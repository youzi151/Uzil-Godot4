extends Node

# Variable ===================

## 辨識
var id : String = ""

## 策略
var _strat = null

## 是否已初始化
var _is_inited := false

## 是否啟用
var _is_active := false

# GDScript ===================

func _init (_strat_or_script_id) :
	if self._is_inited : return
	
	var States = UREQ.acc(&"Uzil:Advance.States")
	
	# 若 為 id字串
	if typeof(_strat_or_script_id) == TYPE_STRING :
		# 試著取得並建立腳本
		var script = States.get_state_script(_strat_or_script_id)
		if script != null :
			self._strat = script.new()
	# 若 為 策略
	else :
		self._strat = _strat_or_script_id
	
	# 若 策略存在
	if self._strat != null :
		# 試 設置 所屬狀態
		if self._strat.has_method("set_state") :
			self._strat.set_state(self)
		
	self._is_inited = true


# Extends ====================

# Public =====================

## 初始化設置
func setup () :
	if self._strat == null : return
	
	# 初始化設置 策略
	if self._strat.has_method("setup") : 
		self._strat.setup()

## 更新
func process (_dt) :
	# 未啟用 則 返回
	if not self._is_active : return
	
	# 試 呼叫 更新
	if self._strat != null :
		if self._strat.has_method("process") :
			self._strat.process(_dt)

## 設置 ID
func set_id (_id: String) :
	self.id = _id
	return self

## 設置 使用主體
func set_user (user) :
	if self._strat == null : return self
	
	if self._strat.has_method("set_user") : 
		self._strat.set_user(user)
	return self

## 設置 資料
func set_data (data) :
	if self._strat == null : return self
	
	if self._strat.has_method("set_data") : 
		self._strat.set_data(data)
	return self

## 當 狀態 進入
func on_enter () :
	# 設置 啟用
	self._is_active = true
	# 試 呼叫 當進入
	if self._strat == null : return
	if self._strat.has_method("on_enter") : 
		await self._strat.on_enter()

## 當 狀態 離開
func on_exit () :
	# 設置 非啟用
	self._is_active = false
	# 試 呼叫 當離開
	if self._strat == null : return
	if self._strat.has_method("on_exit") : 
		await self._strat.on_exit()

# Private ====================

