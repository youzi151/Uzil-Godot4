extends Node

# Variable ===================

## 文字編輯
@export
var text_edit : TextEdit

## 最後滾動的位置
var _last_scroll : float = -1.0

## 是否維持在最底部
var _is_keep_last_line : bool = true

## 佇列中 文字
var _queue_text : String = ""

## 文字是否變更
var _is_text_changed : bool = false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	if self.text_edit == null :
		var slf : Node = self
		if slf is TextEdit :
			self.text_edit = slf
	
	#self.text_edit.text_changed.connect(func():
		#G.print("fallback to %s" % self._last_scroll)
	#)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_delta) :
	
	self._update_text()
	
	self._keep_bottom()
	
	self._is_text_changed = false

func _input (event) :
	# 非 滑鼠按鍵 事件 則 返回
	if not (event is InputEventMouseButton) : return
	var evt = event as InputEventMouseButton
	# 非 按壓中 則 返回
	if not evt.pressed : return 
	# 非 左鍵 則 返回
	if evt.button_index != MOUSE_BUTTON_LEFT : return
	# 非 持有焦點 則 返回
	if not self.text_edit.has_focus() : return 
	# 按壓處 在UI上 則 返回
	if self.text_edit.get_global_rect().has_point(evt.global_position) : return
	
	# 釋放焦點
	self.text_edit.release_focus()
	# 消耗輸入
	self.get_viewport().set_input_as_handled()

func _unhandled_input (event) :
	# 非 滑鼠按鍵 事件 則 返回
	if not (event is InputEventMouseButton) : return
	var evt = event as InputEventMouseButton
	# 非 按壓中 則 返回
	if not evt.pressed : return 
	# 非 滾輪 則 返回
	match evt.button_index :
		MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT : 
			pass
		_ :
			return
	# 按壓點 不在UI上 則 返回
	if not self.text_edit.get_global_rect().has_point(evt.global_position) : return
	# 取得焦點
	self.text_edit.grab_focus()
	
	

# Extends ====================

# Interface ==================

# Public =====================

## 設置 文字
func set_text (msg : String) :
	self._is_text_changed = true
	self.text_edit.text = msg

## 取得 文字
func get_text () -> String :
	return self.text_edit.text

## 添加 文字
func add_text (msg : String) :
	if self.is_editing() :
		self._queue_text += msg
	else :
		self.set_text(self.get_text()+msg)

## 是否編輯中
func is_editing () :
	return self.text_edit.has_focus()
	

# Private ====================

## 保持在底部
func _keep_bottom () :
	if self.text_edit == null : return
	
	# 總行數
	var total_line := self.text_edit.get_line_count()
	
	# 若 編輯中
	if self.is_editing() : 
		# 當前 滾動位置 (可見首行)
		var current_first_line := self.text_edit.scroll_vertical
		# 當前 最後可見一行
		var current_last_line := self.text_edit.get_last_full_visible_line()+2
		
		# 更新 最後滾動位置 為 可見首行
		self._last_scroll = current_first_line
		# 設 是否保持最後一行 為 是否已滾動至底部
		self._is_keep_last_line = current_last_line >= total_line
	
	# 否則
	else :
		# 若 文字 有改變
		if self._is_text_changed :
			
			# 先回到 前次滾動位置
			self.text_edit.scroll_vertical = self._last_scroll
			
			# 若 保持最後一行
			if self._is_keep_last_line :
				# 設置 滾動 到 總行數
				self.text_edit.scroll_vertical = total_line

## 更新 文字
func _update_text () :
	if self.is_editing() : return
	if self._queue_text == "" : return
	self.text_edit.text += self._queue_text
	self._queue_text = ""
	self._is_text_changed = true
