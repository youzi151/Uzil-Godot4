extends Node

@export
var text_edit_np : NodePath
var text_edit : TextEdit

var last_scroll : float = -1.0

var is_keep_last_line : bool = false

var last_text : String

# Called when the node enters the scene tree for the first time.
func _ready():
	if text_edit_np.is_empty() :
		var slf : Node = self
		if slf is TextEdit :
			self.text_edit = slf
	else :
		self.text_edit = self.get_node(text_edit_np)
	
	self.text_edit.text_changed.connect(func():
		print("fallback to %s" % self.last_scroll)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.text_edit == null : return
	
	# 文字是否改變
	var is_text_changed := not self.last_text == self.text_edit.text
	
	if is_text_changed :
		# 記錄最後文字
		self.last_text = self.text_edit.text
		# 先鎖定滾動
		self.text_edit.scroll_vertical = self.last_scroll
	
	# 當前 滾動位置 (可見首行)
	var current_first_line := self.text_edit.scroll_vertical
	# 當前 最後可見一行
	var current_last_line := self.text_edit.get_last_full_visible_line()+2
	# 總行數
	var total_line := self.text_edit.get_line_count()
	
	# 若 文字 沒改變
	if not is_text_changed :
		# 更新 最後滾動位置 為 可見首行
		self.last_scroll = current_first_line
		# 設 是否保持最後一行 為 是否已滾動至底部
		self.is_keep_last_line = current_last_line >= total_line
	# 若 文字 有改變
	else :
		# 若 保持最後一行
		if self.is_keep_last_line :
			# 設置 滾動 到 總行數
			self.text_edit.scroll_vertical = total_line
