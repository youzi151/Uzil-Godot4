
## Input 輸入 公用工具
##
## 取得/處理 輸入 的相關資訊
## 

# Static =====================

## 輸入類型
enum DeviceType {
	KEYBOARD, ## 鍵盤
	MOUSE,    ## 滑鼠
	JOY,      ## 搖桿
	TOUCH     ## 觸控
}

## 數值類型
enum ValueType {
	BUTTON, ## 按鈕
	AXIS    ## 軸
}

## 按鈕狀態
enum ButtonState {
	RELEASE, ## 釋放
	PRESSED, ## 壓住
	DOWN,    ## 正按下
	UP       ## 正彈起
}

# Variable ===================

## 路徑
var PATH : String

## 鍵碼 模塊
var keycode

## 視圖滑鼠 模塊
var viewport_mouse

## 是否 呼叫 按下
#var _is_call_press = false

## 該幀是否已經更新
#var _is_updated = false

## keycode 對 輸入值
var _keycode_to_input_val := {}

var _temp_keycode_to_input_val := {}

## device_type : [device_idx, device_idx]
var updating_devices = [
	DeviceType.KEYBOARD, 
	DeviceType.MOUSE,
	DeviceType.JOY,
	DeviceType.TOUCH,
]

# GDScript ===================

func init (util, modules: Dictionary) :
	
	self.keycode = modules["keycode"]
	self.keycode.init(self)
	
	self.viewport_mouse = modules["viewport_mouse"]
	self.viewport_mouse.init(util)
	
	var Uzil = UREQ.acc("Uzil", "Uzil")
	Uzil.once_loaded(func() :
		Uzil.on_process.on(func(ctrlr):
			self.update()
		)
		Uzil.on_input.on(func(ctrlr):
			self.on_input(ctrlr.data.event)
		)
	)
	
	return self

# Public =====================

## 當輸入
func on_input (event) :
	if event is InputEventMouseButton :
		match event.button_index :
			MOUSE_BUTTON_WHEEL_UP :
				self._set_temp_input_val(self.keycode.name_to_keycode("mouse.wu"), ButtonState.PRESSED)
			MOUSE_BUTTON_WHEEL_DOWN :
				self._set_temp_input_val(self.keycode.name_to_keycode("mouse.wd"), ButtonState.PRESSED)

## 更新
func update () :
	
	if self.updating_devices.has(self.DeviceType.KEYBOARD) :
		self.update_keyboard()
		
	if self.updating_devices.has(self.DeviceType.MOUSE) :
		self.update_mouse()
	
	if self.updating_devices.has(self.DeviceType.JOY) :
		self.update_joys()
	
	if self.updating_devices.has(self.DeviceType.TOUCH) :
		self.update_touch()
	
	self._temp_keycode_to_input_val.clear()

## 更新 裝置 鍵盤
func update_keyboard () :
	# 裝置 keycode前綴
	var device_type_keycode = self.keycode.device_type_to_keycode(DeviceType.KEYBOARD)
	
	# 每個 鍵盤 的 key:資訊
	var key_to_info = self.keycode.get_key_infos(DeviceType.KEYBOARD)
	for key in key_to_info :
		
		# 組合 keycode
		var _keycode = device_type_keycode | key
		# 資訊
		var keyinfo = key_to_info[key]
		# 若 該key 的 值類型 不為 按鍵 則 返回
		if not keyinfo.value_type == ValueType.BUTTON :
			continue
			
		# 更新 按鍵狀態
		self.update_button(DeviceType.KEYBOARD, 0, _keycode, keyinfo)

## 更新 裝置 滑鼠
func update_mouse () :
	# 裝置 keycode前綴
	var device_type_keycode = self.keycode.device_type_to_keycode(DeviceType.MOUSE)
	
	# 每個 滑鼠 的 key:資訊
	var key_to_info = self.keycode.get_key_infos(DeviceType.MOUSE)
	for key in key_to_info :
		# 組合 keycode
		var _keycode = device_type_keycode | key
		# 資訊
		var keyinfo = key_to_info[key]
		# 若 該key 的 值類型 不為 按鍵 則 返回
		if not keyinfo.value_type == ValueType.BUTTON :
			continue
		
		# 更新 按鍵狀態
		self.update_button(DeviceType.MOUSE, 0, _keycode, keyinfo)


## 更新 裝置 搖桿
func update_joys () :
	# 裝置 keycode前綴
	var device_type_keycode = self.keycode.device_type_to_keycode(DeviceType.JOY)
	
	# 每個 搖桿 的 key:資訊
	var key_to_info = self.keycode.get_key_infos(DeviceType.JOY)
	
	var joys = Input.get_connected_joypads()
	
	for idx in range(joys.size()) :
		var device_idx = joys[idx]
	
		for key in key_to_info :
			
			# 組合 keycode
			var _keycode = device_type_keycode | key
			# 資訊
			var keyinfo = key_to_info[key]
			# 若 該key 的 值類型 不為 按鍵 則 返回
			if not keyinfo.value_type == ValueType.BUTTON :
				continue
			
			# 更新 按鍵狀態
			self.update_button(DeviceType.JOY, device_idx, _keycode, keyinfo)

## 更新 裝置 觸碰
func update_touch () :
	# 裝置 keycode前綴
	var device_type_keycode = self.keycode.device_type_to_keycode(DeviceType.TOUCH)
	
	# 每個 觸碰 的 key:資訊
	var key_to_info = self.keycode.get_key_infos(DeviceType.TOUCH)
	for key in key_to_info :
		# 組合 keycode
		var _keycode = device_type_keycode | key
		# 資訊
		var keyinfo = key_to_info[key]
		# 若 該key 的 值類型 不為 按鍵 則 返回
		if not keyinfo.value_type == ValueType.BUTTON :
			continue
		
		# 更新 按鍵狀態
		self.update_button(DeviceType.TOUCH, 0, _keycode, keyinfo)

## 更新 按鈕類
func update_button (device_type: int, device_idx: int, _keycode: int, keyinfo) :
	# 從 暫存 取出 前次輸入值
	var input_val_last = self.get_input(_keycode)
	# 偵測取得 當前 輸入值
	var input_val_curr = self._get_temp_input(_keycode)
	if input_val_curr == null :
		input_val_curr = self.detect_input(device_type, device_idx, keyinfo.value_type, keyinfo.gdkeys)
	
	# 依照 前次輸入值
	match input_val_last :
		# 若 前次 為 釋放
		ButtonState.RELEASE :
			# 當前 為 按壓
			if input_val_curr == ButtonState.PRESSED :
				# 轉為 按壓中
				self._set_input_val(_keycode, ButtonState.DOWN)
		# 若 前次 為 按壓
		ButtonState.PRESSED :
			# 當前 為 釋放
			if input_val_curr == ButtonState.RELEASE :
				# 轉為 釋放中
				self._set_input_val(_keycode, ButtonState.UP)
		# 若 前次 為 釋放中
		ButtonState.UP :
			# 當前 為 釋放
			if input_val_curr == ButtonState.RELEASE :
				# 轉為 已釋放
				self._set_input_val(_keycode, ButtonState.RELEASE)
			# 當前 為 按壓
			if input_val_curr == ButtonState.PRESSED :
				# 轉為 按壓中
				self._set_input_val(_keycode, ButtonState.DOWN)
		# 若 前次 為 按壓中
		ButtonState.DOWN :
			# 當前 為 按壓
			if input_val_curr == ButtonState.PRESSED :
				# 轉為 已按壓
				self._set_input_val(_keycode, ButtonState.PRESSED)
			# 當前 為 釋放
			if input_val_curr == ButtonState.RELEASE :
				# 轉為 釋放中
				self._set_input_val(_keycode, ButtonState.UP)
		# 若 前次 不存在
		null:
			# 直接指定
			self._set_input_val(_keycode, input_val_curr)
		

## 取得 前次輸入 (優先從暫存取得)
func get_input (_keycode: int) :
	if self._keycode_to_input_val.has(_keycode) :
		return self._keycode_to_input_val[_keycode]
	else :
		return null

## 設置 輸入
func _set_input_val (_keycode: int, val) :
	self._keycode_to_input_val[_keycode] = val


## 取得 暫時輸入
func _get_temp_input (_keycode: int) :
	if self._temp_keycode_to_input_val.has(_keycode) :
		return self._temp_keycode_to_input_val[_keycode]
	else :
		return null

## 設置 暫時輸入
func _set_temp_input_val (_keycode: int, val) :
	self._temp_keycode_to_input_val[_keycode] = val

## 偵測 輸入
func detect_input (device_type: int, device_idx: int, val_type: int, gdkeys) :
	match device_type :
		DeviceType.KEYBOARD :
			match val_type :
				ValueType.BUTTON :
					return self.detect_input_keyboard_button(gdkeys)
		DeviceType.MOUSE :
			match val_type :
				ValueType.BUTTON :
					return self.detect_input_mouse_button(gdkeys)
		DeviceType.JOY :
			match val_type :
				ValueType.BUTTON :
					return self.detect_input_joy_button(device_idx, gdkeys)
				ValueType.AXIS :
					return self.detect_input_joy_axis(device_idx, gdkeys)
		DeviceType.TOUCH :
			match val_type :
				ValueType.BUTTON :
					return self.detect_input_touch_button(device_idx, gdkeys)

## 偵測 輸入 鍵盤按鍵
func detect_input_keyboard_button (gdkeys: Array) :
	# 若 任一個 gdkey 按壓中 則 視為 按壓
	for gdkey in gdkeys:
		if Input.is_key_pressed(gdkey) :
			return ButtonState.PRESSED
	# 返回 釋放
	return ButtonState.RELEASE

## 偵測 輸入 滑鼠按鍵
func detect_input_mouse_button (gdkeys: Array) :
	# 若 任一個 gdkey 按壓中 則 視為 按壓
	for gdkey in gdkeys:
		if Input.is_mouse_button_pressed(gdkey) :
			return ButtonState.PRESSED
	# 返回 釋放
	return ButtonState.RELEASE

## 偵測 輸入 搖桿按鍵
func detect_input_joy_button (device_idx: int, gdkeys: Array) :
	# 若 任一個 gdkey 按壓中 則 視為 按壓
	for gdkey in gdkeys:
		if Input.is_joy_button_pressed(device_idx, gdkey) :
			return ButtonState.PRESSED
	# 返回 釋放
	return ButtonState.RELEASE

## 偵測 輸入 搖桿軸
func detect_input_joy_axis (device_idx: int, gdkeys: Array) :
	
	# 值 加總
	var sum : float = 0.0
	# 有效數
	var valid_count : int = 0
	
	# 每個 gdkey
	for gdkey in gdkeys :
		# 取得
		var val = Input.get_joy_axis(device_idx, gdkey)
		# 若 存在 值
		if val != 0 :
			# 加總
			sum = sum + val
			# 增加有效數
			valid_count = valid_count + 1
	
	# 若 無 有效數
	if valid_count == 0 :
		# 返回 0
		return 0
	# 若 有 有效數
	else :
		# 返回 平均值
		return sum / valid_count

## 偵測 輸入 觸碰
func detect_input_touch_button (device_idx: int, gdkeys: Array) :
	# 以 滑鼠左鍵 暫代, 暫時沒有 直接取得 touch方式
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) :
		return ButtonState.PRESSED
	# 返回 釋放
	return ButtonState.RELEASE
