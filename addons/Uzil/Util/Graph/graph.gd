
## 路徑點
class Point :
	## 辨識
	var id : int
	## 權重
	var weight : int
	## ID:下一路徑點 表
	var id_to_next : Dictionary
	## ID:來源路徑點 表 
	## (由來源節點的id_to_next在refresh自動計算而來)
	var id_to_src : Dictionary

# Variable ===================

## ID:路徑點 表
var id_to_point : Dictionary = {}

# GDScript ===================

func _init (_data = null) :
	if _data == null : return
	
	var data : Dictionary = _data
	
	if data.has("points") :
		var points : Dictionary = data["points"]
		for id in points :
			self.set_point(id, points[id])

# Extends ====================

# Interface ==================

# Public =====================

## 取得 路徑點
func get_point (id : int) -> Point :
	if self.id_to_point.has(id) :
		return self.id_to_point[id]
	else :
		return null

## 設置 路徑點
func set_point (id : int, data : Dictionary) : 
	
	var point
	
	if data == null :
		if self.id_to_point.has(id) :
			self.id_to_point.erase(id)
		return
	
	if self.id_to_point.has(id) :
		point = self.id_to_point[id]
	else :
		point = Point.new()
		point.id = id
		self.id_to_point[id] = point
	
	if data.has("weight") : 
		point.weight = data["weight"]
	if data.has("nexts") : 
		point.id_to_next = data["nexts"]
	

## 清空
func clear () :
	self.id_to_point.clear()

## 刷新
func refresh () :
	
	# 每個 點
	for point_id : int in self.id_to_point :
		
		var point : Point = self.id_to_point[point_id]
		
		# 的 每個 接續點
		for next_id : int in point.id_to_next.keys() :
			
			# 若 不存在 則 移除
			if not self.id_to_point.has(next_id) :
				point.id_to_next.erase(next_id)
				continue
			
			# 取得 接續點
			var next_point : Point = self.id_to_point[next_id]
			var edge : int = point.id_to_next[next_id]
			# 把 自己 設置到 接續點 的 來源
			if not next_point.id_to_src.has(point_id) :
				next_point.id_to_src[point_id] = edge
			
	
	#for point_id in self.id_to_point :
		#var point = self.id_to_point[point_id]
		#G.print("%s : %s" % [point_id, point.id_to_src])

## 尋找路徑
func find_path (start_id : int, end_id : int, options : Dictionary = {}) :
	var start_point : Point = self.get_point(start_id)
	var end_point : Point = self.get_point(end_id)
	
	#G.print("find start[%s] -> end[%s]" % [start_id, end_id])
	
	var direction : int = 1
	if options.has("direction") :
		direction = options["direction"]
	
	# 指定 經過路徑點(有序)
	var through_points_exist : bool = options.has("through")
	var through_points : Array = []
	if through_points_exist :
		through_points = options["through"]
	
	# 指定 避開路徑點(無序)
	var without_points_exist : bool = options.has("without")
	var without_points : Array = []
	if without_points_exist :
		without_points = options["without"]
	
	# 指定 必須路徑點(無序)
	var require_points_exist : bool = options.has("require")
	var require_points : Array = []
	if require_points_exist :
		require_points = options["require"]
	
	# 深搜尋 範圍
	# 在 搜尋深度 未達 最小搜尋深度 時, 若 已搜尋到起始點 則 直接返回 (不會有完整 終點路徑資料)
	# 在 搜尋深度 已達 最大搜尋深度 時, 不再繼續搜尋 (避免過度搜尋)
	var deep_find_min := -1
	var deep_find_max := -1
	if options.has("deep_find_range") :
		var deep_find_range : Array = options["deep_find_range"]
		if deep_find_range.size() == 2 :
			deep_find_min = deep_find_range[0]
			deep_find_max = deep_find_range[1]
	
	# 搜尋資料 (可直接指定之前搜尋過的, 就不需重新搜尋)
	var searched_paths : Array = []
	var searched_paths_exist : bool = options.has("searched_paths")
	if searched_paths_exist :
		searched_paths = options["searched_paths"]
	
	# 到達的路徑
	var reached_paths : Array = []
	
	#G.print("input searched_paths")
	#G.print(searched_paths)
	
	# 若 搜尋資料 不存在
	if not searched_paths_exist :
		
		# 檢查佇列
		var queue : Array = [[start_point, []]]
		
		# 當 檢查佇列 還有
		while queue.size() > 0 :
			# 是否 確定加到 搜尋資料 中
			var is_add_to_searched_paths : bool = true
			# 是否 繼續搜尋
			var is_continue_find : bool = true
			
			# 每個 檢查項目 : 尾端, 路徑
			var each_queue : Array = queue.pop_front()
			var last : Point = each_queue[0]
			var path : Array = each_queue[1]
			
			# 若 尾端 已經達到 終點 則 加入 到達的路徑
			if last.id == end_id :
				reached_paths.push_back(path.duplicate())
			
			var id_to_next : Dictionary = last.id_to_next
			if direction == -1 :
				id_to_next = last.id_to_src
			
			# 若 尾端 還有 來源
			if id_to_next.size() != 0 :
				
				# 若 路徑長度 未達 最小搜尋深度
				if path.size() <= deep_find_min :
					# 若 路徑中 已有 終點 則 不繼續
					if end_id in path :
						is_continue_find = false
				
				# 若 路徑長度 未達 最大搜尋深度
				if is_continue_find and path.size() != deep_find_max :
					# 每個 尾端的
					for next_id : int in id_to_next :
						# 若 閉環 則 忽略
						if next_id in path : continue
						
						# 建立 新路徑
						var next : Point = self.get_point(next_id)
						var path_copy : Array = path.duplicate()
						path_copy.push_back(next_id)
						
						# 加入 檢查佇列
						queue.push_back([next, path_copy])
						
						# 先不用加入 搜尋資料
						is_add_to_searched_paths = false
					
				
			# 若 要加到搜尋資料中 則 加入
			if is_add_to_searched_paths :
				searched_paths.push_back(path)
			
			# 若 不繼續搜尋 則 跳出
			if not is_continue_find : break
		
	# 若 搜尋資料 已存在
	else :
		# 整理過 的 搜尋資料
		var searched_path_dict : Dictionary = {}
		
		# 每個 搜尋資料
		for path : Array in searched_paths :
			# 終點 於 路徑中的位置
			var end_idx : int = path.rfind(end_id)
			# 若 不存在終點 則 忽略
			if end_idx == -1 : continue
			
			# 建立 新路徑 為 只取直到終點的路徑
			var path_copy : Array = path.slice(0, end_idx + 1)
			# 若 已經在 整理過的搜尋資料 中 則 忽略
			if searched_path_dict.has(path_copy) : continue
			# 設置 到 整理過的搜尋資料 中
			searched_path_dict[path_copy] = true
			
			# 加入 到 結果路徑 中
			reached_paths.push_back(path_copy)
			
		
	
	#G.print("searched_paths")
	#G.print(searched_paths)
	
	#G.print("reached_paths")
	#G.print(reached_paths)
	
	# 結果路徑
	var result_paths : Array = []
	
	# 每個 到達的路徑
	for path : Array in reached_paths :
		# 若 經過路徑點(有序) 存在
		if through_points_exist :
			var total : int = through_points.size()
			# 剩餘 需要經過數量
			var cur_idx : int = 0
			# 當前指定 經過路徑點
			var cur_through : int = through_points[cur_idx]
			# 每個 路徑中的點
			for each : int in path :
				# 若 符合 當前指定 則
				if each == cur_through :
					# 增加 經過數量
					cur_idx += 1
					# 若 全數經過 則 跳出
					if cur_idx == total : break
					# 移動 當前指定
					cur_through = through_points[cur_idx]
				# 若 不符合 當前指定
				else :
					# 若 非當前指定 的 指定經過路徑點 (順序錯) 則 跳出
					if each in through_points : break
				
			# 若 經過的點 未滿 所有需要經過的點 則
			if cur_idx < total :
				# 該結果路徑 不符合條件 跳過
				continue
				
		# 若 避開路徑點(無序) 存在
		if without_points_exist :
			# 是否通過
			var is_pass : bool = true
			# 每個 避開路徑點
			for each : int in without_points :
				# 若 存在路經中 則 不通過 跳出
				if each in path :
					#G.print("%s is in %s" % [each, path])
					is_pass = false
					break
			# 若 不通過條件 跳過
			if not is_pass :
				continue
			
		# 若 必須路徑點(無序) 存在
		if require_points_exist :
			# 是否通過
			var is_pass : bool = true
			# 每個 必須路徑點
			for each : int in require_points :
				# 若 任一點 不在路徑中 則 不通過 跳出
				if not (each in path) :
					is_pass = false
					break
			# 若 不通過條件 跳過
			if not is_pass :
				continue
		
		#G.print("reached_path : %s added to result" % [path])
		# 加入到 結果路徑
		result_paths.push_back(path)
	
	# 返回結果
	var result : Dictionary = {}
	# 結果路徑
	result["result_paths"] = result_paths
	# 搜尋資料
	result["searched_paths"] = searched_paths
	
	return result

# Private ====================
