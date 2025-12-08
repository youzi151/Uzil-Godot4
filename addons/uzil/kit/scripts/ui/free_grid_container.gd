@tool
extends Control

enum RefreshMode {
	## 每幀更新
	PROCESS, 
	## 手動
	MANUAL,
}

## 靠齊模式
enum AlignMode {
	## 靠齊起始(左)
	BEGIN, 
	## 靠齊中間
	CENTER, 
	## 靠齊末端(右邊)
	END,
}

# Variable ===================

@export_multiline
var debug_txt : String = ""

## 刷新模式
@export
var refresh_mode : RefreshMode = RefreshMode.PROCESS

## 是否適配內容高度
@export
var is_fit_content_height : bool = false

## 靠齊模式
@export
var align_mode_vertical : AlignMode = AlignMode.BEGIN
@export
var align_mode_horizontal : AlignMode = AlignMode.BEGIN

## 排序模式
@export
var is_reverse_vertical : bool = false
@export
var is_reverse_horizontal : bool = false

## 間隔
@export
var seperation : Vector2 = Vector2.ZERO

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	if self.refresh_mode == RefreshMode.PROCESS :
		self.refresh()

# Extends ====================

# Interface ==================

# Public =====================

## 更新
func refresh () :
	
	# 當前位置
	var cur_pos : Vector2 = Vector2.ZERO
	# 此行最高高度
	var height_max_in_row : float = 0.0
	# 此行最高寬度
	var width_max_in_row : float = 0.0
	# 容器尺寸
	var container_size : Vector2 = self.size
	# 內容總高
	var content_total_height : float = 0.0
	
	# 當前行
	var cur_row : Array = []
	# 所有行
	var rows : Array = [cur_row]
	# 行與該行寬度
	var row_to_width_max : Array = []
	
	# 每個 子節點
	var childs : Array[Node] = self.get_children()
	var childs_size : int = childs.size()
	for idx in childs_size+1 :
		# 當前子節點
		var child : Control = null
		# 縮放過的尺寸
		var scaled_size : Vector2 = Vector2.ZERO
		# 是否超出數量範圍
		var is_out_of_bound : bool = idx >= childs_size
		
		# 若 沒超出 則 取得 子節點 與 尺寸
		if not is_out_of_bound :
			child = childs[idx]
			scaled_size = child.size * child.scale.abs()
		
		# 右側 (當前位置x+縮放過的寬度)
		var right_side : float = cur_pos.x + scaled_size.x
		
		# 若 需要進入下一行 (右側 超過 容器寬度 或 超出範圍數量) 
		if right_side > container_size.x or is_out_of_bound :
			
			# 紀錄 總高 為 當前指標 + 當前行最高高度
			content_total_height = cur_pos.y + height_max_in_row
			# 紀錄 當前行 寬度
			row_to_width_max.push_back(width_max_in_row)
			
			# 若 超出數量範圍 則 忽略
			if is_out_of_bound : continue
			
			# 設 當前位置橫向 為 零
			cur_pos.x = 0.0
			# 更新右側 為 當前位置橫向(0.0) + 縮放後寬度
			right_side = scaled_size.x
			# 設 當前位置縱向 為 目前內容總高 + 分隔高度
			cur_pos.y = content_total_height + self.seperation.y
			# 當前行 最高節點高度 歸零
			height_max_in_row = 0.0
			# 當前行 寬度 歸零
			width_max_in_row = 0.0
			
			# 建立新行
			cur_row = []
			rows.push_back(cur_row)
		
		# 若 超出數量範圍 則 忽略
		if is_out_of_bound : continue
		
		# 加入 該子節點相關資訊 至 此行
		var to_pos : Vector2 = cur_pos
		cur_row.push_back([child, to_pos, scaled_size])
		
		# 當前位置橫向 增加 縮放過的寬度 + 分隔寬度
		cur_pos.x += scaled_size.x + self.seperation.x
		
		# 若 該節點縮放過的高度 大於 最高節點高度 則 取代
		if scaled_size.y > height_max_in_row :
			height_max_in_row = scaled_size.y
		
		# 若 右側超過 原本 當前行寬度 則 取代
		if right_side > width_max_in_row :
			width_max_in_row = right_side
	
	# 所有 行
	for row_idx in rows.size() :
		# 所有 子節點 in 行
		var row : Array = rows[row_idx]
		for each in row :
			var child = each[0]
			var pos : Vector2 = each[1]
			var siz : Vector2 = each[2]
			
			# 若 反轉 橫向
			if self.is_reverse_horizontal :
				pos.x = row_to_width_max[row_idx] - pos.x - siz.x
			# 若 反轉 縱向
			if self.is_reverse_vertical :
				pos.y = content_total_height - pos.y - siz.y
			
			# 依照 橫向 靠齊模式
			match self.align_mode_horizontal :
				AlignMode.CENTER :
					var width_max = row_to_width_max[row_idx]
					var padding : float = (container_size.x - width_max) * 0.5
					pos.x += padding
				AlignMode.END :
					var width_max = row_to_width_max[row_idx]
					var padding : float = (container_size.x - width_max)
					pos.x += padding
			
			# 若 適配內容高度
			if is_fit_content_height :
				# 設 此節點 高度 為 內容總高度
				self.custom_minimum_size.y = content_total_height
			# 若 不適配
			else :
				# 依照 縱向 靠齊模式
				match self.align_mode_vertical :
					AlignMode.CENTER :
						var width_max = row_to_width_max[row_idx]
						var padding : float = (container_size.y - content_total_height) * 0.5
						pos.y += padding
					AlignMode.END :
						var width_max = row_to_width_max[row_idx]
						var padding : float = (container_size.y - content_total_height)
						pos.y += padding
			
			# 設置 實際位置
			child.set_position(pos)

# Private ====================
