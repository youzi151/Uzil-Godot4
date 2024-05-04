extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

@export
var test_ui_list : Array[Node] = []

## 輸入
var input = null

## ui導航 實例
var ui_nav_inst = null

var input_listening_time : float = 0.1
var _input_listening_time : float = 0.0

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_ui_nav")
	
	self.input = UREQ.acc("Uzil", "Util").input
	
	# ui 初期設置
	self.test_ui_setup()

func _process (_dt) :
	self.test_process(_dt)

func _exit_tree () :
	G.off_print("test_ui_nav")

# Extends ====================


func test_process (_delta: float) :
	var dir = Vector2.ZERO
	
	# 取得 不同方向 的 按鍵輸入
	
	# 上下左右
	var input_w = self.input.get_input(self.input.keycode.name_to_keycode("key.w"))
	var input_x = self.input.get_input(self.input.keycode.name_to_keycode("key.x"))
	var input_d = self.input.get_input(self.input.keycode.name_to_keycode("key.d"))
	var input_a = self.input.get_input(self.input.keycode.name_to_keycode("key.a"))
	# 斜向
	var input_q = self.input.get_input(self.input.keycode.name_to_keycode("key.q"))
	var input_e = self.input.get_input(self.input.keycode.name_to_keycode("key.e"))
	var input_z = self.input.get_input(self.input.keycode.name_to_keycode("key.z"))
	var input_c = self.input.get_input(self.input.keycode.name_to_keycode("key.c"))
	
	#G.print("w[%s] a[%s] s[%s] d[%s] " % [input_w, input_s, input_d, input_a])
	
	# 判斷 是否釋放
	var is_release_w = input_w == self.input.ButtonState.RELEASE
	var is_release_a = input_a == self.input.ButtonState.RELEASE
	var is_release_x = input_x == self.input.ButtonState.RELEASE
	var is_release_d = input_d == self.input.ButtonState.RELEASE
	
	var is_release_q = input_q == self.input.ButtonState.RELEASE
	var is_release_e = input_e == self.input.ButtonState.RELEASE

	var is_release_z = input_z == self.input.ButtonState.RELEASE
	var is_release_c = input_c == self.input.ButtonState.RELEASE
	
	# 若 全釋放 則 輸入偵聽時間 歸零
	if is_release_w and is_release_a and is_release_x and is_release_d and is_release_q and is_release_e and is_release_z and is_release_c:
		self._input_listening_time = 0
	# 若 任一按壓
	else :
		# 推進 輸入偵聽時間
		self._input_listening_time += _delta
		# 若超過數入偵聽時間 則 
		if self._input_listening_time > self.input_listening_time :
			# 輸入偵聽時間歸零
			self._input_listening_time = 0
			
			# 依照按壓狀態 決定 導航方向
			if not is_release_w :
				dir.y += -1
			if not is_release_a :
				dir.x += -1
			if not is_release_d :
				dir.x +=  1
			if not is_release_x :
				dir.y +=  1
			
			if not is_release_q :
				dir.x += -1
				dir.y += -1
			if not is_release_e :
				dir.x +=  1
				dir.y += -1
			if not is_release_z :
				dir.x += -1
				dir.y +=  1
			if not is_release_c :
				dir.x +=  1
				dir.y +=  1
			
			# 前往導航 傳入方向
			self.ui_nav_inst.go_nav({"dir":dir})
			G.print("UI nav to dir : %s" % dir)
			

# Public =====================

func test_ui_setup () :
	var ui_nav_mgr = UREQ.acc("Uzil", "ui_nav_mgr")
	
	# 取得 實例
	var inst = ui_nav_mgr.inst("test_ui")
	self.ui_nav_inst = inst
	# 清空
	self.ui_nav_inst.clear()
	
	# 原點
	var chain_origin = inst.new_chain("origin", "vec2", {
		"target":null,
		# 取得 位置getter
		"pos_getter":func():
			# 以 各個UI 的 平均中心點 為 位置
			var center_pos := Vector2.ZERO
			for each in self.test_ui_list :
				center_pos += each.position
			return center_pos / self.test_ui_list.size()
	})
	
	# 建立 各鏈節點
	var chain_a = inst.new_chain("a", "vec2", {"target":self.test_ui_list[0]})
	var chain_b = inst.new_chain("b", "vec2", {"target":self.test_ui_list[1]})
	var chain_c = inst.new_chain("c", "vec2", {"target":self.test_ui_list[2]})
	
	# 添加 鄰近關係
	chain_origin.add_neighbors([chain_a.id, chain_b.id, chain_c.id])
	chain_a.add_neighbors([chain_b.id, chain_c.id])
	chain_b.add_neighbors([chain_a.id, chain_c.id])
	chain_c.add_neighbors([chain_a.id, chain_b.id])
	
	# 設置 待機鏈節點 為 原點
	inst.set_idle_chain(chain_origin.id)
	
	# 註冊 當 鏈節點變更
	inst.on_chain_change.on(func(ctrlr):
		var last = ctrlr.data["last"]
		var next = ctrlr.data["next"]
		
		# 若 前個 鏈節點 存在
		if last != null :
			
			# 呼叫 該鏈節點 測試用UI導航離開行為
			var last_target = last.data.target
			if last_target != null :
				if last_target.has_method("on_ui_nav_exit") :
					last_target.on_ui_nav_exit.call()
					
				
			last = last.id
		
		# 若 下個鏈節點 存在
		if next != null : 
			
			# 呼叫 該鏈節點 測試用UI導航進入行為
			var next_target = next.data.target
			if next_target != null :
				if next_target.has_method("on_ui_nav_enter") :
					next_target.on_ui_nav_enter.call()
			
			next = next.id
		
		G.print("change chain from %s to %s" % [last, next])
	)

## 測試 偵錯Log
func test_log () :
	G.print("==== start test log =============")
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
	# 取得 實例
	var ui_nav_mgr = UREQ.acc("Uzil", "ui_nav_mgr")
	var inst = ui_nav_mgr.inst("test_log")
	# 清空
	inst.clear()
	
	# 原點
	var chain_origin = inst.new_chain("origin", "vec2", {"pos":Vector2(0, 0)})
	
	# 建立 各鏈節點
	var pos_d = Vector2( 5,  10)
	var pos_e = Vector2( 0, -20)
	var pos_f = Vector2(10,   0)
	#   d
	#       f
	#   
	#  e
	var chain_d = inst.new_chain("d", "vec2", {"pos":pos_d})
	var chain_e = inst.new_chain("e", "vec2", {"pos":pos_e})
	var chain_f = inst.new_chain("f", "vec2", {"pos":pos_f})
	G.print("d: %s" % pos_d)
	G.print("e: %s" % pos_e)
	G.print("f: %s" % pos_f)
	
	# 添加 鄰近關係
	chain_origin.add_neighbors([chain_d.id, chain_e.id, chain_f.id])
	chain_d.add_neighbors([chain_e.id])
	chain_e.add_neighbors([chain_d.id, chain_f.id])
	chain_f.add_neighbors([chain_e.id])
	
	# 設置 待機鏈節點 為 原點
	inst.set_idle_chain(chain_origin.id)

	var array_util = UREQ.acc("Uzil", "Util").array
	
	# 註冊 當 鏈節點變更
	inst.on_chain_change.on(func(ctrlr):
		var last = ctrlr.data["last"]
		if last != null : last = last.id
		var next = ctrlr.data["next"]
		if next != null : next = next.id
		G.print("change chain from %s to %s" % [last, next])
	)
	
	# 當前鏈節點
	var current_chain = chain_origin
	var last_chain = null
	G.print("current chain : %s" % [current_chain.id])
	
	G.print("==============")
	# 印出 往 上方 導航
	G.print("next nav, go  (-0.1, 10) (up)")
	# 印出 每個鄰近鏈節點ID
	G.print("get_nearest_neighbor :")
	G.print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	
	# 往 上方 導航
	inst.go_nav({"dir":Vector2(-0.1, 10)})
	# 更新 當前鏈節點
	last_chain = current_chain
	current_chain = inst.get_current()
	G.print("current chain : %s" % [current_chain.id])
	
	
	G.print("==============")
	# 印出 往 左方 導航 (但帶有 弧度上限)
	G.print("next nav, go (-20, -1) (left) but with default angle_max(0.33PI)(60d)")
	# 印出 每個鄰近鏈節點ID
	G.print("get_nearest_neighbor :")
	G.print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	
	# 往 左方 導航 (限制 弧度上限 約45角度)
	inst.go_nav({"dir":Vector2(-20, -1)})
	# 更新 當前鏈節點
	last_chain = current_chain
	current_chain = inst.get_current()
	G.print("current chain : %s" % [current_chain.id])
	
	
	G.print("==============")
	# 回上個鏈節點
	inst.go_chain(last_chain)
	# 印出 往 左方 導航
	G.print("next nav, go (-20, -1) (left)  but with angle_max(PI)(180d)")
	# 印出 每個鄰近鏈節點ID
	G.print("get_nearest_neighbor :")
	G.print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	
	# 往 左方 導航 (限制 弧度上限 約180角度)
	inst.go_nav({"dir":Vector2(-20, -1), "angle_max": PI})
	# 更新 當前鏈節點
	last_chain = current_chain
	current_chain = inst.get_current()
	G.print("current chain : %s" % [current_chain.id])

