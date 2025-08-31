
# Variable ===================

var setting_key_is_advance_print : String = "global_util/logger/is_advance_print"

## 偵聽者
var _on_print_listeners := []
var _on_error_listeners := []
## 已加入的函式
var _on_print_added_fn := []
var _on_error_added_fn := []

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 印出print
func do_print (msg) :
	# 是否 進階印出
	var is_advance_print := false
	# 若 有在專案設定中 設定
	if ProjectSettings.has_setting(self.setting_key_is_advance_print) :
		is_advance_print = ProjectSettings.get_setting(self.setting_key_is_advance_print)
	
	# 若 進階印出
	if is_advance_print :
		var from : Dictionary = get_stack()[2]
		print("--------------\n  %s\n  at: %s:%s - %s()" % [msg, from.source, from.line, from.function])
	# 一般印出
	else :
		print(msg)
	
	if typeof(msg) != TYPE_STRING :
		msg = str(msg)
	for each in self._on_print_listeners :
		each.fn.call(msg)

## 註冊 當印出
func on_print (fn: Callable, tag: String = "") :
	if fn in self._on_print_added_fn :
		return
	else :
		self._on_print_added_fn.push_back(fn)
		
	var listener := {
		"fn" : fn,
		"tag" : tag,
	}
	self._on_print_listeners.push_back(listener)
	return listener

## 註銷 當印出
func off_print (tag: String = "") :
	if tag == "" : return
	
	for idx in range(self._on_print_listeners.size()-1, -1, -1) :
		var each = self._on_print_listeners[idx]
		if each.tag == tag :
			self._on_print_listeners.remove_at(idx)
		if each.fn in self._on_print_added_fn :
			self._on_print_added_fn.erase(each.fn)
		
	

## 報錯
func do_error (msg) :
	push_error(msg)
	if typeof(msg) != TYPE_STRING :
		msg = str(msg)
	for each in self._on_error_listeners :
		each.fn.call(msg)

## 註冊 當印出
func on_error (fn: Callable, tag: String = "") :
	if fn in self._on_error_added_fn :
		return
	else :
		self._on_error_added_fn.push_back(fn)
		
	var listener := {
		"fn" : fn,
		"tag" : tag,
	}
	self._on_error_listeners.push_back(listener)
	return listener

## 註銷 當印出
func off_error (tag: String = "") :
	if tag == "" : return
	
	for idx in range(self._on_print_listeners.size()-1, -1, -1) :
		var each = self._on_error_listeners[idx]
		if each.tag == tag :
			self._on_error_listeners.remove_at(idx)
		if each.fn in self._on_error_added_fn :
			self._on_error_added_fn.erase(each.fn)

# Private ====================
