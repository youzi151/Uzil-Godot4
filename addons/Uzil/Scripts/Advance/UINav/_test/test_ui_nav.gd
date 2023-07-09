extends Uzil_Test_Base

# Variable ===================

var input = null
var ui_nav_inst = null

@export var test_ui_list : Array[NodePath] = []

var input_listening_time : float = 0.1
var _input_listening_time : float = 0.0

# Extends ====================

func test_ready () :
	self.input = UREQ.acc("Uzil", "Util").input
	
	self.test_log()
	self.test_ui()

func test_process(_delta):
	var dir = Vector2.ZERO
	
	var input_w = self.input.get_input(self.input.keycode.name_to_keycode("key.w"))
	var input_x = self.input.get_input(self.input.keycode.name_to_keycode("key.x"))
	var input_d = self.input.get_input(self.input.keycode.name_to_keycode("key.d"))
	var input_a = self.input.get_input(self.input.keycode.name_to_keycode("key.a"))
	
	var input_q = self.input.get_input(self.input.keycode.name_to_keycode("key.q"))
	var input_e = self.input.get_input(self.input.keycode.name_to_keycode("key.e"))
	var input_z = self.input.get_input(self.input.keycode.name_to_keycode("key.z"))
	var input_c = self.input.get_input(self.input.keycode.name_to_keycode("key.c"))
	
#	print("w[%s] a[%s] s[%s] d[%s] " % [input_w, input_s, input_d, input_a])
	
	var is_release_w = input_w == self.input.ButtonState.RELEASE
	var is_release_a = input_a == self.input.ButtonState.RELEASE
	var is_release_x = input_x == self.input.ButtonState.RELEASE
	var is_release_d = input_d == self.input.ButtonState.RELEASE
	
	var is_release_q = input_q == self.input.ButtonState.RELEASE
	var is_release_e = input_e == self.input.ButtonState.RELEASE
	var is_release_z = input_z == self.input.ButtonState.RELEASE
	var is_release_c = input_c == self.input.ButtonState.RELEASE
	
	
	if is_release_w and is_release_a and is_release_x and is_release_d and is_release_q and is_release_e and is_release_z and is_release_c:
		self._input_listening_time = 0
	else :
		self._input_listening_time += _delta
		if self._input_listening_time > self.input_listening_time :
			self._input_listening_time = 0
			
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
			
			self.ui_nav_inst.go_nav({"dir":dir})
			print(dir)
			

# Public =====================

func test_ui () :
	var ui_nav_mgr = UREQ.acc("Uzil", "ui_nav_mgr")
	
	var inst = ui_nav_mgr.inst("test_ui")
	self.ui_nav_inst = inst
	
	var ui_list := []
	for each in self.test_ui_list :
		ui_list.push_back(self.get_node(each))
		
	var chain_origin = inst.new_chain("origin", "vec2", {
		"pos_getter":func () :
			var center_pos := Vector2.ZERO
			for each in ui_list :
				center_pos += each.position
			print("A")
			return center_pos / ui_list.size()
	})
	
	var chain_a = inst.new_chain("a", "vec2", {"target":ui_list[0]})
	var chain_b = inst.new_chain("b", "vec2", {"target":ui_list[1]})
	var chain_c = inst.new_chain("c", "vec2", {"target":ui_list[2]})
	
	chain_origin.add_neighbors([chain_a.id, chain_b.id, chain_c.id])
	chain_a.add_neighbors([chain_b.id, chain_c.id])
	chain_b.add_neighbors([chain_a.id, chain_c.id])
	chain_c.add_neighbors([chain_a.id, chain_b.id])
	
	inst.set_idle_chain(chain_origin.id)
	
	inst.on_chain_change.on(func(ctrlr):
		var last = ctrlr.data["last"]
		var next = ctrlr.data["next"]
		
		if last != null :
			
			var last_target = last.data.target
			if last_target != null :
				if last_target.has_method("on_ui_nav_exit") :
					last_target.on_ui_nav_exit.call()
					
			last = last.id
			
		if next != null : 
			
			var next_target = next.data.target
			if next_target != null :
				if next_target.has_method("on_ui_nav_enter") :
					next_target.on_ui_nav_enter.call()
			
			next = next.id
		
		print("change chain from %s to %s" % [last, next])
	)


func test_log () :
	
	var invoker_mgr = UREQ.acc("Uzil", "invoker_mgr")
	
	var ui_nav_mgr = UREQ.acc("Uzil", "ui_nav_mgr")
	var inst = ui_nav_mgr.inst("test_log")
	
	var chain_origin = inst.new_chain("origin", "vec2", {"pos":Vector2(0, 0)})
	
	var chain_a = inst.new_chain("a", "vec2", {"pos":Vector2(-1, 10)})
	var chain_b = inst.new_chain("b", "vec2", {"pos":Vector2( 0, 10)})
	var chain_c = inst.new_chain("c", "vec2", {"pos":Vector2( 1, 10)})
	
	chain_origin.add_neighbors([chain_a.id, chain_b.id, chain_c.id])
	chain_a.add_neighbors([chain_b.id])
	chain_b.add_neighbors([chain_a.id, chain_c.id])
	chain_c.add_neighbors([chain_b.id])

	inst.set_idle_chain(chain_origin.id)

	var array_util = UREQ.acc("Uzil", "Util").array
	
	inst.on_chain_change.on(func(ctrlr):
		var last = ctrlr.data["last"]
		if last != null : last = last.id
		var next = ctrlr.data["next"]
		if next != null : next = next.id
		print("change chain from %s to %s" % [last, next])
	)

	var current_chain
	
	current_chain = chain_origin
	print("current chain : %s" % [current_chain.id])
	
	print("go -0.1, 10 (up)")
	print("get_nearest_neighbor :")
	print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	inst.go_nav({"dir":Vector2(-0.1, 10)})
	current_chain = inst.get_current()
	print("current chain : %s" % [current_chain.id])
	
	print("go -1, -20 (down) but with angle_max")
	print("get_nearest_neighbor :")
	print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	inst.go_nav({"dir":Vector2(-1, -20), "angle_max": 0.25 * PI})
	current_chain = inst.get_current()
	print("current chain : %s" % [current_chain.id])
	
	print("go -1, -20 (down) ")
	print("get_nearest_neighbor :")
	print(array_util.map(current_chain.get_neighbor_chains(), func(idx, val) : return val.id))
	inst.go_nav({"dir":Vector2(-1, -20)})
	current_chain = inst.get_current()
	print("current chain : %s" % [current_chain.id])

