extends Node

# Variable ===================

## 進度條UI
@export var progress_bar_sub_NP : NodePath = ""
var progress_bar_sub

@export var progress_bar_total_NP : NodePath = ""
var progress_bar_total

@export var progress_bar_step_NP : NodePath = ""
var progress_bar_step

# 更新任務
var update_task

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.progress_bar_sub = self.get_node(self.progress_bar_sub_NP)
	self.progress_bar_total = self.get_node(self.progress_bar_total_NP)
	self.progress_bar_step = self.get_node(self.progress_bar_step_NP)
	
	# 讀取 更新器
	var uzupdater = load("res://addons/Uzupdater/Scripts/uzupdater.gd").new()
	self.add_child(uzupdater)
	
	self.clear_test(uzupdater)
	
#	Uzil_Init.init()
#
#	G.Uzil.invoker.inst().once(func():
#		print("hi")
#	, 3)
	
	
	# 開始更新
	self.update_task = uzupdater.start_update(func():
		# 當 更新完畢
		
		print("uzupdater update done !")
		
		var uzil_init = ResourceLoader.load("res://addons/Uzil/Scripts/uzil_init.gd", "", ResourceLoader.CACHE_MODE_IGNORE).new()
		uzil_init.free()
#
#		G.Uzil.invoker.inst().once(func():
#			print("ddd")
#		, 3)
		
		# 更新 進度顯示
		self.update_progress("update main", ["file","main"])
	)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	
	# 若 在更新 更新器
	if self.update_task.state == self.update_task.uzupdater.Task.UPDATE_STATE.Uzupdater :
		# 更新進度 找帶有"file", "uzupdater" tag 的 進度
		self.update_progress("update uzupdater", ["file","uzupdater"])
		
	# 若 在更新 主要內容
	elif self.update_task.state == self.update_task.uzupdater.Task.UPDATE_STATE.Main :
		# 更新進度 找帶有"file", "main" tag 的 進度
		self.update_progress("update main", ["file","main"])

# Extends ====================

# Public =====================

## 更新進度顯示
func update_progress (msg, tags) :
	
	# 取得 總進度 百分比
	var progress_percent = self.update_task.get_progress_percent()
	self.progress_bar_total.set_progress(progress_percent)
	self.progress_bar_total.set_text("%2.1f%%" % (progress_percent * 100))
	
	
	# 取得 當前子進度 百分比
	var sub_progress_percent : float = 1.0
	var current_sub_progress = self.update_task.get_sub_progress()
	if current_sub_progress != null :
		if current_sub_progress.max > 0 :
			sub_progress_percent = float(current_sub_progress.cur) / float(current_sub_progress.max)
		
	self.progress_bar_sub.set_progress(sub_progress_percent)
	self.progress_bar_sub.set_text("%2.1f%%" % (sub_progress_percent * 100.0))
	
	# 從更新任務中 取得 階段進度
	var progress_step = self.update_task.get_progress_step(tags)
	
	var step_bar := 0.0
	var step_text := ""
	if progress_step.max > 0 :
		step_bar = float(progress_step.cur) / float(progress_step.max)
		step_text = "%s : %d/%d" % [msg, progress_step.cur, progress_step.max]
	
	self.progress_bar_step.set_progress(step_bar)
	self.progress_bar_step.set_text(step_text)
	
# Private ====================

## 清除測試檔案
func clear_test (uzupdater) :
	
	var last_downloaded_path = ProjectSettings.globalize_path(uzupdater.PATH.path_join("_test/download_local"))
	if not DirAccess.dir_exists_absolute(last_downloaded_path) : return
	
	OS.move_to_trash(last_downloaded_path)
