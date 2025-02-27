extends Node

## Scroll 滾動容器 與 多個滾動條 綁定
## 
## 使 滾動容器 與 多個滾動條 的 滾動位置, 滾動頁面 數值同步/表現一致.
##

# Variable ===================

## 滾動容器
@export 
var scroll_container : ScrollContainer

## 垂直 滾動條
@export 
var v_scroll_bars : Array[VScrollBar]

## 水平 滾動條
@export 
var h_scroll_bars : Array[HScrollBar]

## 是否滾動中
var is_scrolling : bool = false

# GDScript ===================

# Called when the node enters the scene tree for the first time.
func _ready () :
	# 所以滾動條滾動時, 更新
	for each in self.v_scroll_bars :
		each.scrolling.connect(self._update_v_scroll.bind(each))
	for each in self.h_scroll_bars :
		each.scrolling.connect(self._update_h_scroll.bind(each))

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	
	# 取得 滾動容器 中的 滾動資訊
	var v_bar : VScrollBar = self.scroll_container.get_v_scroll_bar()
	var h_bar : HScrollBar = self.scroll_container.get_h_scroll_bar()
	
	# 滾動位置
	var v_scroll_percent : float = v_bar.value / v_bar.max_value
	# 滾動頁面長度
	var v_page_percent : float = v_bar.page / v_bar.max_value
	# 頁面是否滿條 (滿 則 隱藏)
	var v_is_full : bool = v_page_percent >= 1
	# 每個 滾動條 設置 頁面, 位置, 是否顯示
	for each in self.v_scroll_bars :
		each.page = each.max_value * v_page_percent
		each.value = each.max_value * v_scroll_percent
		each.visible = not v_is_full
	
	# 滾動位置
	var h_scroll_percent : float = h_bar.value / h_bar.max_value
	# 滾動頁面長度
	var h_page_percent : float = h_bar.page / h_bar.max_value
	# 頁面是否滿條 (滿 則 隱藏)
	var h_is_full : bool = h_page_percent >= 1
	# 每個 滾動條 設置 頁面, 位置, 是否顯示
	for each in self.h_scroll_bars :
		each.page = each.max_value * h_page_percent
		each.value = each.max_value * h_scroll_percent
		each.visible = not h_is_full
		

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

## 更新 垂直滾動 (以 特定滾動條滾動狀態 為主)
func _update_v_scroll (scroll_by: VScrollBar) :
	# 滾動位置 百分比
	var percent : float = scroll_by.value / scroll_by.max_value
	# 設置 其他滾動條位置 為 一致
	for each in self.v_scroll_bars :
		if each == scroll_by : continue
		each.value = each.max_value * percent
	# 設置 滾動容器 位置 為 一致
	var v_bar : VScrollBar = self.scroll_container.get_v_scroll_bar()
	v_bar.value = v_bar.max_value * percent

## 更新 水平滾動 (以 特定滾動條滾動狀態 為主)
func _update_h_scroll (scroll_by: HScrollBar) :
	# 滾動位置 百分比
	var percent : float = scroll_by.value / scroll_by.max_value
	# 設置 其他滾動條位置 為 一致
	for each in self.h_scroll_bars :
		if each == scroll_by : continue
		each.value = each.max_value * percent
	# 設置 滾動容器 位置 為 一致
	var h_bar : HScrollBar = self.scroll_container.get_h_scroll_bar()
	h_bar.value = h_bar.max_value * percent
