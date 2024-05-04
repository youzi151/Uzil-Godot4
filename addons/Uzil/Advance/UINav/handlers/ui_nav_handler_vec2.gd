
enum Vec2Type {
	DIR,
	NEAR,
}

# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

## 設置 資料
func set_data (chain, data) :
	if data.has("target") :
		chain.data.target = data.target
		
	if data.has("pos") :
		chain.data.position = data.pos
	elif data.has("position") :
		chain.data.position = data.position
	
	if data.has("pos_getter") :
		chain.data.pos_getter = data.pos_getter

## 初始化
func init (chain) :
	pass

## 推進
func process (chain, _dt) :
	pass

## 當 鏈節點 進入
func on_enter (chain) :
	pass

## 當 鏈節點 離開
func on_exit (chain) :
	pass

## 取得 鄰近值 (提供別的鏈結點進行比較)
func get_near_val (chain, key: String, req_data := {}) :
	if key == "pos2D" :
		if chain.data.has("position") :
			return chain.data.position
		elif chain.data.has("pos_getter") :
			return chain.data.pos_getter.call()
		elif chain.data.has("target") :
			return chain.data.target.position
		else :
			print("%s has no pos2D val" % chain.id)
			print(chain.data)
	return null

## 取得 最近的 鄰近 鏈節點
func get_nearest_neighbor (chain, req_data := {}) :
	
#	print("get_nearest_neighbor")
#	print(UREQ.acc("Uzil", "Util").array.map(chain.get_neighbor_chains(), func(idx, val) :
#		return val.id
#	))
	
	var type_and_val = self.get_vec2_type_val(req_data)
	if type_and_val == null : return null
	var typ = type_and_val[0]
	var val = type_and_val[1]
	
	if typ == Vec2Type.DIR :
		
		var dir : Vector2 = val
		var pos = chain.get_near_val("pos2D", req_data)
		if pos == null : return null
		
		var angle_max := 0.33 * PI # == 6x degree
		if req_data.has("angle_max") :
			angle_max = req_data["angle_max"]
		
		var nearest = null
		var nearest_angle : float = PI
		
		for each in chain.get_neighbor_chains() :
			var each_pos = each.get_near_val("pos2D", req_data)
			if each_pos == null : continue
			
			var each_dir = each_pos - pos
			var angle = abs(dir.angle_to(each_dir))
#			print("angle %s -> %s : dir[%s] dir_input[%s] = angle: %s" % [chain.id, each.id, each_dir, dir, angle])
			
			if angle > angle_max : continue
			
			
			if angle <= nearest_angle :
				nearest_angle = angle
				nearest = each
				
		return nearest
		
	elif typ == Vec2Type.NEAR :
		
		var nearest = null
		var nearest_dis : float = val
		
		var pos = chain.get_near_val("pos2D", req_data)
		
		for each in chain.get_neighbor_chains() :
			var each_pos = each.get_near_val("pos2D", req_data)
			if each_pos == null : continue
			
			var distance = pos.distance_to(each_pos)
			if distance < nearest_dis :
				nearest_dis = distance
				nearest = each
			
		return nearest

# Public =====================

# Private ====================

func get_vec2_type_val (req_data) :
	
	if req_data.has("dir") :
		return [Vec2Type.DIR, req_data["dir"]]
	elif req_data.has("nearest_in") :
		return [Vec2Type.NEAR, req_data["nearest_in"]]
		
	return null
