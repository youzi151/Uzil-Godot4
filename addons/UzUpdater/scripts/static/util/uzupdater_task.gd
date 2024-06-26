
## Uzupdater Task 任務
##
## 紀錄, 表示 一次更新的狀態, 資料...等所需資訊
##

# Const ======================

enum UPDATE_STATE {
	None = 0,
	Uzupdater = 1,
	Main = 2,
	Done = 99,
}

# Variable ===================

var uzupdater = null

## 狀態
var state : int = UPDATE_STATE.None

## 是否完成
var is_done := false

## 版本資料 原先
var version_data_last := {}

## 版本資料 新版
var version_data_new := {}
var version_data_new_str := ""

## 進度
var current_sub_progress_key := ""
var _progress := []
var _key_to_progress_idx := {}

## 資料
var _data := {}

# GDScript ===================

# Extends ====================

# Public =====================

## 取得 進度 階段
func get_progress_step (_include_tags : PackedStringArray = []) :
	var cur := 0
	var sum := 0
	var is_tag_filter = _include_tags.size() > 0
	for each in self._progress :
		if is_tag_filter :
			var is_include = true
			for tag in _include_tags :
				if not each.tags.has(tag) :
					is_include = false
					break
			if not is_include : continue
		
		sum += 1
		
		if each.max < 0 : continue
		if each.cur < each.max : continue
		
		cur += 1
		
	return {"cur":cur, "max":sum}

## 取得 進度 百分比
func get_progress_percent () :
	if self._progress.size() == 0 :
		return 1.0
	
	var cur := 0.0
	var sum := 0.0
	for each in self._progress :
		cur += each.cur
		if each.max >= 0 :
			sum += each.max
		else :
			sum += each.cur + 1.0
	if sum == 0 : return 0.0
	return min(cur / sum, 1)

## 請求 子進度
func request_sub_progress (_key := "") -> Dictionary :
	if self._key_to_progress_idx.has(_key) :
		var idx = self._key_to_progress_idx[_key]
		return self._progress[idx]
	else :
		var new_sub_progress = { "cur":0.0, "max":-1.0, "tags":[]}
		var idx = self._progress.size()
		self._progress.push_back(new_sub_progress)
		self._key_to_progress_idx[_key] = idx
		return new_sub_progress

## 取得 當前或指定 子進度
func get_sub_progress (_key := "") :
	if _key == "" :
		if self.current_sub_progress_key != "" :
			_key = self.current_sub_progress_key
		else :
			var size = self._progress.size()
			if size > 0 :
				return self._progress[size-1]
			else :
				return null
	
	var idx = self._key_to_progress_idx[_key]
	return self._progress[idx]

## 請求 更新器 資料
func request_updater_data (updater) :
	if self._data.has(updater) :
		return self._data[updater]
	else :
		var data := {}
		self._data[updater] = data
		return data

## 清空 更新器 資料
func erase_updater_data (updater) :
	if not self._data.has(updater) : return
	self._data[updater].clear()
	self._data.erase(updater)

# Private ====================
