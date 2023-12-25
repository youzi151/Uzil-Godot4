
## SumVals.Inst 總結數值
##
## 每筆資料持有多個子資料, 可依照自身的值 與 子資料 的 總結算值 進行 總結算.[br]
## 透過不同的路由, 可建立與取得不同階層的資料. [br]
## 須先設置 總結值函式 來 指定 每筆資料 如何將 自己的值 以及 子資料的總結值 計算為自己總結值 的函式.[br]
## 另可設置 結果覆寫函式 來 方便 在取得 最終值
##

# Variable ===================

## 路由:資料表
var _route_to_data := {}

## 根資料
var _root_data = null

## 總結值 函式
var _summary_val_fn : Callable

## 結果覆寫 函式
var _result_modifier_fn : Callable

# GDScript ===================

func _init () :
	self._root_data = self._new_data("", null)
	self._summary_val_fn = func (val, _sub_vals) : return val
	self._result_modifier_fn = func (val) : return val
	
# Public =====================

## 設置 總結 函式
func set_summary_val_fn (fn : Callable) :
	self._summary_val_fn = fn

## 設置 結果修改 函式
func set_result_modifier_fn (fn : Callable) :
	self._result_modifier_fn = fn

## 設置預設
func set_default (val) :
	self._root_data.val = val
	self._root_data.summary_val = val

## 設置
func set_val (route, val, is_update := true) :
	# 取得 或 建立 資料
	var data = self._get_data(route)
	
	# 設置 值
	data.val = val
	
	# 若 需要 刷新 則
	if is_update :
		# 刷新 直到 該節點 (不用更新該資料的子資料) 並在其中 總結自己
		self._update_until(data)
	else :
		# 僅 總結自己
		data.summary_val = self._sum_val(data)
## 移除
func del_route (route, is_update = true) :
	# 取得 該資料
	var data = self._get_data(route, false)
	if data == null : return
	
	# 遞迴 移除 該資料的子資料
	for sub_data in data.sub_datas :
		self.del_route(sub_data, false)
		
	# 從 註冊表 移除自己
	self._route_to_data.erase(route)
	
	# 從 上層資料 移除自己
	data.parent_data.sub_datas.erase(data)
	
	# 呼叫 自己 的 刷新事件
	var update_result = self._result_modifier_fn.call(null)
	data.on_update.emit(update_result)
	
	# 若 需要刷新 的 則
	if is_update :
		# 總刷新 (不須使用"直到"因為自身已經被移除)
		self.update()

## 清空
func clear () :
	# 清空 根資料
	self._root_data.clear()
	
	# 所有資料
	var to_rm_datas := self._route_to_data.values()
	
	# 清空註冊表
	self._route_to_data.clear()
	
	# 每筆資料 發送 刷新事件 值為空 
	for each in to_rm_datas :
		each.on_update.emit(self._result_modifier_fn.call(null))

## 刷新
func update () :
	self._update_data(self._root_data, null, null)

## 刷新 (直到特定資料)
func _update_until (data) :
	self._update_data(self._root_data, data, null)
	
## 刷新 資料
func _update_data (data, _until_data = null, _exist_to_call_on_update = null) :
	print("update : %s" % data.route)

	# 是否 遞迴中 為 現有待呼叫刷新事件的資料列表 是否存在
	var is_recursive = _exist_to_call_on_update != null
	
	# 待呼叫刷新事件的資料列表
	var to_call_on_update : Array = []
	# 若 遞迴中 則 取用 現有
	if is_recursive :
		to_call_on_update = _exist_to_call_on_update
	
	# 若 該資料 不為 終點
	if data != _until_data :
		# 每筆 子資料
		for sub_data in data.sub_datas :
			self._update_data(sub_data, _until_data, to_call_on_update)
	
	# 計算 總結值
	var last_val = data.summary_val
	var new_sum_val = self._sum_val(data)
	
	# 是否 總結值 有變更
	var is_sum_val_changed : bool = last_val != new_sum_val
	print("%s has changed? %s" % [data.route, is_sum_val_changed])
	print("%s -> %s" % [data.summary_val, new_sum_val])
	
	# 若 有變更 則 設置
	if is_sum_val_changed :
		data.summary_val = new_sum_val
	
	# 若 已脫離 遞迴
	if not is_recursive :
		# 每個 待呼叫的 刷新事件
		for each in to_call_on_update :
			var update_result = self._result_modifier_fn.call(each.summary_val)
			# 呼叫 刷新事件
			each.on_update.emit(update_result)
	
	# 若 總結值 有變更
	if is_sum_val_changed :
		
		# 若 遞迴中
		if is_recursive :
			# 加入 待呼叫
			to_call_on_update.push_back(data)
			
		# 若 已脫離 遞迴
		else :
			# 直接 呼叫 刷新事件
			var update_result = self._result_modifier_fn.call(data.summary_val)
			data.on_update.emit(update_result)
	

## 取得 幒結值
func get_sum_val (route) :
	# 取得 資料
	var data = self._get_data(route, false)
	if data == null : return null
	
	return data.summary_val

## 註冊 當更新
func on_update (route, listener_or_fn) :
	# 取得 或 建立 資料
	var data = self._get_data(route)
	return data.on_update.on(listener_or_fn)

## 註銷 當更新
func off_update (route, listener_or_tag) :
	# 取得 資料
	var data = self._get_data(route, false)
	if data == null : return
	return data.on_update.off(listener_or_tag)

## 取得 資料
func _get_data (route_or_data, is_new_if_not_exist = true) :
	
	var data = null
	
	# 若 為 空 則 為 根資料
	if route_or_data == null or route_or_data == "" :
		data = self._root_data
	
	# 若 存在註冊表中 則 返回 該資料
	elif self._route_to_data.has(route_or_data) :
		data = self._route_to_data[route_or_data]
	
	# 若 不存在 且 不存在時可建立 則 建立 資料
	elif is_new_if_not_exist :
		
		# 以 上一層路由 取得 或 建立 上層資料
		var parent_data
		
		# 上一層路由
		var route : String = (route_or_data as String)
		var routes := Array(route.split("."))
		routes.pop_back()
		
		# 若 路由存在 則 
		if routes.size() > 0 : 
			# 取得 資料 (以串接後的路由)
			parent_data = self._get_data(".".join(routes))
		# 不存在 則 視為 根資料
		else :
			parent_data = self._root_data
		
		# 建立 新資料
		data = self._new_data(route_or_data, parent_data)
		
		# 註冊
		self._route_to_data[route_or_data] = data
		
		# 加入 到 上層資料中
		parent_data.sub_datas.push_back(data)
		
	return data

## 建立 資料
func _new_data (route, parent) :
	var SumVals = UREQ.acc("Uzil", "SumVals")
	var data = SumVals.Data.new()
	
	data.route = route
	data.parent_data = parent
	
	return data


## 計算 總結值
func _sum_val (data) :
	
	var sub_vals := []
	
	for sub_data in data.sub_datas :
		if sub_data.is_effect_parent :
			sub_vals.push_back(sub_data.summary_val)
		
	var sum_val
	if data.override_summary_fn != null :
		sum_val = data.override_summary_fn(data.val, sub_vals)
	else :
		sum_val = self._summary_val_fn.call(data.val, sub_vals)
	
	return sum_val
