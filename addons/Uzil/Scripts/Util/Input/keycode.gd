
## Keycode 鍵碼
##
## 定義各種輸入裝置與輸入鍵的代碼
## 

## 輸入裝置類型 遮罩
const DEVICE_TYPE_MASK     := 0b01111000000000000
## 輸入裝置類型 遮罩 偏移
const DEVICE_TYPE_SHIFT    := 12
## 裝置編號 遮罩
const DEVICE_ID_MASK       := 0b00000111100000000
## 裝置編號 遮罩 偏移
const DEVICE_ID_SHIFT      := 8

## Uzil格式中的key編號 遮罩
const KEYCODE_MASK         := 0b00000000011111111

var uzil_input

## 名稱:鍵值 快取
var _name_to_keycode_cache := {}

## 名稱:key, key:godotkey 查詢表
var _keycode_table := {}

## 裝置類型:keycode資訊
var device_type_to_keycode_infos := {}

## 初始化
func init (uzil_input) :
	self.uzil_input = uzil_input
	self._init_raw(uzil_input)
	return self

## 取得 裝置類型
func get_device_type (keycode) -> int :
	return (keycode & self.DEVICE_TYPE_MASK) >> self.DEVICE_TYPE_SHIFT

## 取得 輸入裝置序號
func get_device_index (keycode) -> int :
	return (keycode & self.DEVICE_ID_MASK) >> self.DEVICE_ID_SHIFT

## 取得 輸入鍵
func get_key (keycode) -> int :
	return (keycode & self.KEYCODE_MASK)

## 取得 裝置類型 的 key:資訊
func get_key_infos (device_type) :
	if self.device_type_to_keycode_infos.has(device_type) :
		return self.device_type_to_keycode_infos[device_type]
	else :
		return null

## 以 名稱 取得 gdkeys
func name_to_gdkeys (name) :
	var _keycode = self.name_to_keycode(name)
	if _keycode == null :
		return null
	
	var device_type = self.get_device_type(_keycode)
	var gdkeys = self.key_to_gdkeys(device_type, _keycode)
	
	return gdkeys

## 以 名稱 取得 gdkeys
func key_to_gdkeys (device_type, key) :
	# 若 找不到 該裝置類型 的 表
	if not self._keycode_table.has(device_type) :
		return null
	
	# 取得 key : gdkeys
	var _key_to_gdkeys = self._keycode_table[device_type][1]
	
	# 若 對應的gdkeys 不存在
	if not _key_to_gdkeys.has(key) :
		return null
		
	return _key_to_gdkeys[key]
	

## 以 名稱 取得 key
func name_to_keycode (name_str : String) :
	# 一律視為小寫
	name_str = name_str.to_lower()
	
	# 若 快取 中 有 該名稱 則 直接取用
	if self._name_to_keycode_cache.has(name_str) :
		return self._name_to_keycode_cache[name_str]
	
	# 拆分 字串
	var name_arr := name_str.split(".", false, 2)
	
	# 至少要兩個 1.裝置 2.鍵
	var arrsize = name_arr.size()
	if arrsize < 2 :
		return null
	
	# 輸入裝置類型 字串
	var name_typ : String = name_arr[0]
	# 裝置編號
	var name_device := 0
	# 鍵 字串
	var name_key := "none"
	
	# 依照 字串數量
	match arrsize :
		# 若 為2個 則 取 第2個 為 鍵
		2 :
			name_key    = name_arr[1]
		# 若 為2個 則 取 第2個 為 裝置編號, 第3個 為 鍵	
		3 :
			name_device = int(name_arr[1])
			name_key    = name_arr[2]
	
	# 輸入裝置類型
	var type_key
	# 該裝置的鍵表
	var name_to_key
	
	# 依照 輸入裝置類型
	match name_typ :
		# 鍵盤
		"key" :
			type_key = self.device_type_to_keycode(self.uzil_input.DeviceType.KEYBOARD)
			name_to_key = self._keycode_table[self.uzil_input.DeviceType.KEYBOARD][0]
		# 滑鼠
		"mouse" :
			type_key = self.device_type_to_keycode(self.uzil_input.DeviceType.MOUSE)
			name_to_key = self._keycode_table[self.uzil_input.DeviceType.MOUSE][0]
		# 搖桿
		"joy" :
			type_key = self.device_type_to_keycode(self.uzil_input.DeviceType.JOY)
			name_to_key = self._keycode_table[self.uzil_input.DeviceType.JOY][0]
	
	# 產生 裝置編號 的 key值
	var device_idx = name_device << self.DEVICE_ID_SHIFT
	
	# 若 鍵表 有 存在 該名稱的key
	if name_to_key.has(name_key) :
		# 組成鍵值
		var key = (type_key) | (device_idx & self.DEVICE_ID_MASK) | (name_to_key[name_key] & self.KEYCODE_MASK)
		# 記錄快取
		self._name_to_keycode_cache[name_key] = key
		return key
	# 若 不存在 則 返回 空
	else :
		return null

## 轉換 裝置類型 至 keycode
func device_type_to_keycode (device_type) :
	return device_type << self.DEVICE_TYPE_SHIFT

## 讀取 原始資料 至 表 
func raw_to_dict (device_type, raw) :
	
	# 建立或取得 查詢表
	var tb
	if self._keycode_table.has(device_type) :
		tb = self._keycode_table[device_type]
	else :
		tb = [{}, {}]
		self._keycode_table[device_type] = tb
	
	# 名稱:key查詢表
	var name_to_key = tb[0]
	# key:gdkeys查詢表
	var _key_to_gdkeys = tb[1]
	
	# 建立或取得 該裝置類型 的 keycode:資訊
	var keycode_to_info : Dictionary
	if self.device_type_to_keycode_infos.has(device_type) :
		keycode_to_info = self.device_type_to_keycode_infos[device_type]
	else :
		keycode_to_info = {}
		self.device_type_to_keycode_infos[device_type] = keycode_to_info
	
	# 每一筆 元資料
	for each in raw :
		var key : int = each[0]
		var names : Array = each[1]
		var val_type : int = each[2]
		var gdkeys : Array = each[3]
		
		# 加入 名稱:key 查詢表
		for name in names :
			name_to_key[name] = key
		
		# 加入 key:gdkey 查詢表
		_key_to_gdkeys[key] = gdkeys.duplicate()
			
		# 加入 key:資訊
		var info = {}
		info.names = names.duplicate()
		info.value_type = val_type
		info.gdkeys = gdkeys.duplicate()
		
		keycode_to_info[key] = info
		

## 初始化 元資料
func _init_raw (uzil_input) :
	
	var ValueType = uzil_input.ValueType
	
	var KEYS_RAW_KEYBOARD = [
		[0, ["", "none"], ValueType.BUTTON, [KEY_NONE]],
		
		[1,  ["a"], ValueType.BUTTON, [KEY_A]],
		[2,  ["b"], ValueType.BUTTON, [KEY_B]],
		[3,  ["c"], ValueType.BUTTON, [KEY_C]],
		[4,  ["d"], ValueType.BUTTON, [KEY_D]],
		[5,  ["e"], ValueType.BUTTON, [KEY_E]],
		[6,  ["f"], ValueType.BUTTON, [KEY_F]],
		[7,  ["g"], ValueType.BUTTON, [KEY_G]],
		[8,  ["h"], ValueType.BUTTON, [KEY_H]],
		[9,  ["i"], ValueType.BUTTON, [KEY_I]],
		[10, ["j"], ValueType.BUTTON, [KEY_J]],
		[11, ["k"], ValueType.BUTTON, [KEY_K]],
		[12, ["l"], ValueType.BUTTON, [KEY_L]],
		[13, ["m"], ValueType.BUTTON, [KEY_M]],
		[14, ["n"], ValueType.BUTTON, [KEY_N]],
		[15, ["o"], ValueType.BUTTON, [KEY_O]],
		[16, ["p"], ValueType.BUTTON, [KEY_P]],
		[17, ["q"], ValueType.BUTTON, [KEY_Q]],
		[18, ["r"], ValueType.BUTTON, [KEY_R]],
		[19, ["s"], ValueType.BUTTON, [KEY_S]],
		[20, ["t"], ValueType.BUTTON, [KEY_T]],
		[21, ["u"], ValueType.BUTTON, [KEY_U]],
		[22, ["v"], ValueType.BUTTON, [KEY_V]],
		[23, ["w"], ValueType.BUTTON, [KEY_W]],
		[24, ["x"], ValueType.BUTTON, [KEY_X]],
		[25, ["y"], ValueType.BUTTON, [KEY_Y]],
		[26, ["z"], ValueType.BUTTON, [KEY_Z]],

		[30, ["0", ")"], ValueType.BUTTON, [KEY_0]],
		[31, ["1", "!"], ValueType.BUTTON, [KEY_1]],
		[32, ["2", "@"], ValueType.BUTTON, [KEY_2]],
		[33, ["3", "#"], ValueType.BUTTON, [KEY_3]],
		[34, ["4", "$"], ValueType.BUTTON, [KEY_4]],
		[35, ["5", "%"], ValueType.BUTTON, [KEY_5]],
		[36, ["6", "^"], ValueType.BUTTON, [KEY_6]],
		[37, ["7", "&"], ValueType.BUTTON, [KEY_7]],
		[38, ["8", "*"], ValueType.BUTTON, [KEY_8]],
		[39, ["9", "("], ValueType.BUTTON, [KEY_9]],
		
		[40, ["-", "_" ], ValueType.BUTTON, [KEY_UNDERSCORE, KEY_MINUS]],
		[41, ["=", "+" ], ValueType.BUTTON, [KEY_EQUAL, KEY_PLUS]],
		[42, ["[", "{" ], ValueType.BUTTON, [KEY_BRACKETLEFT, KEY_BRACELEFT]],
		[43, ["]", "}" ], ValueType.BUTTON, [KEY_BRACKETRIGHT, KEY_BRACERIGHT]],
		[44, ["\\", "|"], ValueType.BUTTON, [KEY_BACKSLASH, KEY_BAR]],
		[45, ["`", "~" ], ValueType.BUTTON, [KEY_QUOTELEFT, KEY_ASCIITILDE]],
		[46, [";", ":" ], ValueType.BUTTON, [KEY_SEMICOLON, KEY_COLON]],
		[47, ["'", '"' ], ValueType.BUTTON, [KEY_APOSTROPHE, KEY_QUOTEDBL]],
		[48, [",", "<" ], ValueType.BUTTON, [KEY_COMMA, KEY_LESS]],
		[49, [".", ">" ], ValueType.BUTTON, [KEY_PERIOD, KEY_GREATER]],
		[50, ["/", "?" ], ValueType.BUTTON, [KEY_SLASH, KEY_QUESTION]],
		
		[61, ["f1" ], ValueType.BUTTON, [KEY_F1]],
		[62, ["f2" ], ValueType.BUTTON, [KEY_F2]],
		[63, ["f3" ], ValueType.BUTTON, [KEY_F3]],
		[64, ["f4" ], ValueType.BUTTON, [KEY_F4]],
		[65, ["f5" ], ValueType.BUTTON, [KEY_F5]],
		[66, ["f6" ], ValueType.BUTTON, [KEY_F6]],
		[67, ["f7" ], ValueType.BUTTON, [KEY_F7]],
		[68, ["f8" ], ValueType.BUTTON, [KEY_F8]],
		[69, ["f9" ], ValueType.BUTTON, [KEY_F9]],
		[70, ["f10"], ValueType.BUTTON, [KEY_F10]],
		[71, ["f11"], ValueType.BUTTON, [KEY_F11]],
		[72, ["f12"], ValueType.BUTTON, [KEY_F12]],
		[73, ["f13"], ValueType.BUTTON, [KEY_F13]],
		[74, ["f14"], ValueType.BUTTON, [KEY_F14]],
		[75, ["f15"], ValueType.BUTTON, [KEY_F15]],
		[76, ["f16"], ValueType.BUTTON, [KEY_F16]],
		[77, ["f17"], ValueType.BUTTON, [KEY_F17]],
		[78, ["f18"], ValueType.BUTTON, [KEY_F18]],
		[79, ["f19"], ValueType.BUTTON, [KEY_F19]],
		[80, ["f20"], ValueType.BUTTON, [KEY_F20]],
		[81, ["f21"], ValueType.BUTTON, [KEY_F21]],
		[82, ["f22"], ValueType.BUTTON, [KEY_F22]],
		[83, ["f23"], ValueType.BUTTON, [KEY_F23]],
		[84, ["f24"], ValueType.BUTTON, [KEY_F24]],
		
		[90,  ["return", "enter"], ValueType.BUTTON, [KEY_ENTER]],
		[91,  ["escape"         ], ValueType.BUTTON, [KEY_ESCAPE]],
		[92,  ["backspace"      ], ValueType.BUTTON, [KEY_BACKSPACE]],
		[93,  ["tab"            ], ValueType.BUTTON, [KEY_TAB]],
		[94,  ["space"          ], ValueType.BUTTON, [KEY_SPACE]],
		[95,  ["cap"            ], ValueType.BUTTON, [KEY_CAPSLOCK]],
		[96,  ["ctrl"           ], ValueType.BUTTON, [KEY_CTRL]],
		[97,  ["alt"            ], ValueType.BUTTON, [KEY_ALT]],
		[98,  ["shift"          ], ValueType.BUTTON, [KEY_SHIFT]],
		[101, ["left"           ], ValueType.BUTTON, [KEY_LEFT]],
		[102, ["up"             ], ValueType.BUTTON, [KEY_UP]],
		[103, ["right"          ], ValueType.BUTTON, [KEY_RIGHT]],
		[104, ["down"           ], ValueType.BUTTON, [KEY_DOWN]],
		[105, ["printscreen"    ], ValueType.BUTTON, [KEY_PRINT]],
		[106, ["scrolllock"     ], ValueType.BUTTON, [KEY_SCROLLLOCK]],
		[107, ["pause"          ], ValueType.BUTTON, [KEY_PAUSE]],
		[108, ["insert"         ], ValueType.BUTTON, [KEY_INSERT]],
		[109, ["delete"         ], ValueType.BUTTON, [KEY_DELETE]],
		[110, ["pageup"         ], ValueType.BUTTON, [KEY_PAGEUP]],
		[111, ["pagedown"       ], ValueType.BUTTON, [KEY_PAGEDOWN]],
		[112, ["home"           ], ValueType.BUTTON, [KEY_HOME]],
		[113, ["end"            ], ValueType.BUTTON, [KEY_END]],
		[120, ["kp0"            ], ValueType.BUTTON, [KEY_KP_0]],
		[121, ["kp1"            ], ValueType.BUTTON, [KEY_KP_1]],
		[122, ["kp2"            ], ValueType.BUTTON, [KEY_KP_2]],
		[123, ["kp3"            ], ValueType.BUTTON, [KEY_KP_3]],
		[124, ["kp4"            ], ValueType.BUTTON, [KEY_KP_4]],
		[125, ["kp5"            ], ValueType.BUTTON, [KEY_KP_5]],
		[126, ["kp6"            ], ValueType.BUTTON, [KEY_KP_6]],
		[127, ["kp7"            ], ValueType.BUTTON, [KEY_KP_7]],
		[128, ["kp8"            ], ValueType.BUTTON, [KEY_KP_8]],
		[129, ["kp9"            ], ValueType.BUTTON, [KEY_KP_9]],
		[131, ["kp+"            ], ValueType.BUTTON, [KEY_KP_ADD]],
		[132, ["kp-"            ], ValueType.BUTTON, [KEY_KP_SUBTRACT]],
		[133, ["kp*"            ], ValueType.BUTTON, [KEY_KP_MULTIPLY]],
		[134, ["kp/"            ], ValueType.BUTTON, [KEY_KP_DIVIDE]],
		[135, ["kp."            ], ValueType.BUTTON, [KEY_KP_PERIOD]],
		[137, ["kpenter"        ], ValueType.BUTTON, [KEY_KP_ENTER]],
		
	]

	var KEYS_RAW_MOUSE = [
		[0, ["none"], ValueType.BUTTON, [KEY_NONE] ],
		[1, ["lmb" ], ValueType.BUTTON, [MOUSE_BUTTON_LEFT] ],
		[2, ["rmb" ], ValueType.BUTTON, [MOUSE_BUTTON_RIGHT] ],
		[3, ["mmb" ], ValueType.BUTTON, [MOUSE_BUTTON_MIDDLE] ],
		[4, ["wu"  ], ValueType.BUTTON, [MOUSE_BUTTON_WHEEL_UP] ],
		[5, ["wd"  ], ValueType.BUTTON, [MOUSE_BUTTON_WHEEL_DOWN] ],
		[6, ["wl"  ], ValueType.BUTTON, [MOUSE_BUTTON_WHEEL_LEFT] ],
		[7, ["wr"  ], ValueType.BUTTON, [MOUSE_BUTTON_WHEEL_RIGHT] ],
		[8, ["xmb1"], ValueType.BUTTON, [MOUSE_BUTTON_XBUTTON1] ],
		[9, ["xmb2"], ValueType.BUTTON, [MOUSE_BUTTON_XBUTTON2] ],
	]

	var KEYS_RAW_JOY = [
		[0,  ["none"    ], ValueType.BUTTON, [KEY_NONE] ],
		[1,  ["a"       ], ValueType.BUTTON, [JOY_BUTTON_A] ],
		[2,  ["b"       ], ValueType.BUTTON, [JOY_BUTTON_B] ],
		[3,  ["x"       ], ValueType.BUTTON, [JOY_BUTTON_X] ],
		[4,  ["y"       ], ValueType.BUTTON, [JOY_BUTTON_Y] ],
		[5,  ["back"    ], ValueType.BUTTON, [JOY_BUTTON_BACK] ],
		[6,  ["guild"   ], ValueType.BUTTON, [JOY_BUTTON_GUIDE] ],
		[7,  ["start"   ], ValueType.BUTTON, [JOY_BUTTON_START] ],
		[8,  ["ls"      ], ValueType.BUTTON, [JOY_BUTTON_LEFT_STICK] ],
		[9,  ["rs"      ], ValueType.BUTTON, [JOY_BUTTON_RIGHT_STICK] ],
		[10, ["lb"      ], ValueType.BUTTON, [JOY_BUTTON_LEFT_SHOULDER] ],
		[11, ["rb"      ], ValueType.BUTTON, [JOY_BUTTON_RIGHT_SHOULDER] ],
		[12, ["lt"      ], ValueType.AXIS, [JOY_AXIS_TRIGGER_LEFT] ], # axis特例處理
		[13, ["rt"      ], ValueType.AXIS, [JOY_AXIS_TRIGGER_RIGHT] ], # axis特例處理
		[14, ["lsu"     ], ValueType.AXIS, [JOY_AXIS_LEFT_Y] ], # axis特例處理
		[15, ["lsd"     ], ValueType.AXIS, [JOY_AXIS_LEFT_Y] ], # axis特例處理
		[16, ["lsl"     ], ValueType.AXIS, [JOY_AXIS_LEFT_X] ], # axis特例處理
		[17, ["lsr"     ], ValueType.AXIS, [JOY_AXIS_LEFT_X] ], # axis特例處理
		[18, ["rsu"     ], ValueType.AXIS, [JOY_AXIS_RIGHT_Y] ], # axis特例處理
		[19, ["rsd"     ], ValueType.AXIS, [JOY_AXIS_RIGHT_Y] ], # axis特例處理
		[20, ["rsl"     ], ValueType.AXIS, [JOY_AXIS_RIGHT_X] ], # axis特例處理
		[21, ["rsr"     ], ValueType.AXIS, [JOY_AXIS_RIGHT_X] ], # axis特例處理
		[22, ["dpu"     ], ValueType.BUTTON, [JOY_BUTTON_DPAD_UP] ],
		[23, ["dpd"     ], ValueType.BUTTON, [JOY_BUTTON_DPAD_DOWN] ],
		[24, ["dpl"     ], ValueType.BUTTON, [JOY_BUTTON_DPAD_LEFT] ],
		[25, ["dpr"     ], ValueType.BUTTON, [JOY_BUTTON_DPAD_RIGHT] ],
		[26, ["misc1"   ], ValueType.BUTTON, [JOY_BUTTON_MISC1] ],
		[27, ["paddle1" ], ValueType.BUTTON, [JOY_BUTTON_PADDLE1] ],
		[28, ["paddle2" ], ValueType.BUTTON, [JOY_BUTTON_PADDLE2] ],
		[29, ["paddle3" ], ValueType.BUTTON, [JOY_BUTTON_PADDLE3] ],
		[30, ["paddle4" ], ValueType.BUTTON, [JOY_BUTTON_PADDLE4] ],
		[31, ["touchpad"], ValueType.BUTTON, [JOY_BUTTON_TOUCHPAD] ],
	]
	
	self.raw_to_dict(uzil_input.DeviceType.KEYBOARD, KEYS_RAW_KEYBOARD)
	self.raw_to_dict(uzil_input.DeviceType.MOUSE, KEYS_RAW_MOUSE)
	self.raw_to_dict(uzil_input.DeviceType.JOY, KEYS_RAW_JOY)
