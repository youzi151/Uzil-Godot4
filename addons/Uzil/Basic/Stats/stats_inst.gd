
## TODO
# 做成一個具有tag, filter...等功能的統計與查詢

# Variable ===================

var _Stats = null

var _key_to_data : Dictionary = {}

var _query_fn : Callable

var _summary_fn : Callable

# GDScript ===================

func _init () :
	self._Stats = UREQ.acc(&"Uzil:Basic.Stats")

# Extends ====================

# Interface ==================

# Public =====================

## 設置 數據
func set_stat (key: String, val, opts := {}) :
	var data = null
	if self._key_to_data.has(key) :
		data = self._key_to_data[key]
	else :
		data = self._Stats.Data.new()
		self._key_to_data[key] = data
	
	data.val = val
	
	return data

## 修改 數據
func mod_stat (key: String, fn: Callable, opts := {}) :
	var stat = self.get_stat(key)
	if stat == null :
		stat = self.set_stat(key, null)
	fn.call(stat)

## 取得 數據
func get_stat (key: String) :
	if not self._key_to_data.has(key) : return null
	return self._key_to_data[key]

## 取得 數據
func query_stats (opts := {}) :
	if self._query_fn.is_null() :
		return self.default_query(opts)
	else :
		return self._query_fn.call(opts)

## 設置 總計 函式
func set_query_fn (query_fn: Callable) :
	self._query_fn = query_fn

## 總計
func summary (opts := {}) :
	if self._summary_fn.is_null() : 
		return self.default_summary(opts)
	else :
		return self._summary_fn.call(opts)

## 設置 總計 函式
func set_summary_fn (sum_fn: Callable) :
	self._summary_fn = sum_fn

# Private ====================

func default_query (opts := {}) :
	# temp
	return self._key_to_data

func default_summary (opts := {}) :
	var stats : Dictionary = self.query_stats(opts)
	var result : Dictionary = {}
	for key in stats :
		result[key] = stats[key].val
	return result
