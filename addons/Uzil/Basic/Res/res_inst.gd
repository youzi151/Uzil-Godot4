extends Node

## Uzil.Basic.Res.Inst 資源管理 實體
##
## 提供 預載資源配置擋, 預載資源, 持有(讀取)資源 功能.
## 若有需要特殊的讀取資源方式, 也可添加 對應資源讀取器.
##

# Variable ===================

## 預設持有者
const DEFAULT_HOLDER = "_ures_prehold"

## 公用
var Util = null

## 內建 讀取器
var built_in_loader = null

## 預設 讀取器
var default_loader = null

## 讀取器表
var id_to_loader := {}

## 預載表
var id_to_prehold := {}

## 路徑:檔案路徑 快取
var path_to_file_path := {}

## 是否偵錯
var is_debug := false

# GDScript ===================

func _init () :
	var Uzil = UREQ.acc("Uzil", "Uzil")
	var Res = UREQ.acc("Uzil", "Res")
	
	self.Util = UREQ.acc("Uzil", "Util")
	
	self.built_in_loader = Uzil.load_script(Res.PATH.path_join("loaders/res_loader_built_in.gd")).new(self)
	self.set_loader("_built_in", self.built_in_loader)
	
	self.default_loader = self.built_in_loader

func _process (_dt) :
	self.built_in_loader.process(_dt)

# Extends ====================

# Interface ==================

# Public =====================

## 設置 讀取器
func set_loader (id: String, loader) :
	if id == "" :
		if loader != null :
			self.default_loader = loader
	else :
		if loader != null :
			self.id_to_loader[id] = loader
		else :
			self.id_to_loader.erase(id)

# Hold/Drop =========

## 持有
func hold (full_path: String, holder = null, options = null) :
	
	# 讀取器
	var loader = self.default_loader
	var loader_id := ""
	
	# 選項
	if options != null :
		# 試取得 讀取器
		if options.has("loader") :
			var opt_loader_id = options["loader"]
			if opt_loader_id != "" and self.id_to_loader.has(opt_loader_id) :
				loader_id = opt_loader_id
				loader = self.id_to_loader[loader_id]
	
	var res_info = null
	# 若 該讀取器 存在 該路徑資源 則 取用
	if loader.res_exist(full_path, options) :
		res_info = loader.res_get(full_path, options)
	# 否則
	else :
		# 讀取 該資源
		res_info = await loader.res_load(full_path, options)
		
		if res_info != null : 
			# 設置ID
			res_info.id = self.make_res_info_id(full_path, loader_id)
	
	# 若 有指定 持有者 則 設置持有
	if holder != null :
		res_info.hold(holder)
		
	return res_info

## 釋放
func drop (res_info, holder) :
	self._print("ures.drop:%s" % holder)
	# 若 指定 資源
	if res_info != null :
		# 若 指定 持有者 則 釋放 該持有者
		if holder != null :
			return res_info.drop(holder)
		# 若 無指定 持有者 則 釋放 所有持有者
		else :
			return res_info.drop_all()
	# 若 無指定 資源
	else :
		# 若 指定 持有者 則 
		if holder != null :
			# 每個 讀取器 對 所有資源 釋放 該持有者
			for each_loader in self.id_to_loader.values() :
				each_loader.res_drop(null, holder)
		# 若 無指定 持有者
		else :
			# 每個 讀取器 對 所有資源 釋放 所有持有者
			for each_loader in self.id_to_loader.values() :
				each_loader.res_drop(null, null)
	

# Prehold ===========

## 預載
func prehold (full_path: String, options = null) :
	
	var loader_id := ""
	
	# 若 選項 存在
	if options != null :
		# 從 options 中 試取得loader
		if options.has("loader") :
			var opt_loader_id = options["loader"]
			if opt_loader_id != "" and self.id_to_loader.has(opt_loader_id) :
				loader_id = opt_loader_id
	
	# 建構ID
	var id = self.make_res_info_id(full_path, loader_id)
	
	var res_info
	# 若 該id 的 預載ResInfo 存在 則 取用
	if self.id_to_prehold.has(id) :
		res_info = self.id_to_prehold[id]
	# 否則 以 DEFAULT_HOLDER 來 持有 資源
	else :
		res_info = await self.hold(full_path, self.DEFAULT_HOLDER, options)
	
	return res_info

## 解除預載
func unprehold (full_path: String, loader_id: String = "") :
	var loader = self.default_loader
	# 建構ID
	var id = self.make_res_info_id(full_path, loader_id)
	# 若 未持有 該預載ResInfo 則 返回
	if not self.id_to_prehold.has(id) : return
	
	# 取得
	var res_info = self.id_to_prehold[id]
	# 以 DEFAULT_HOLDER 釋放該資源
	res_info.drop(self.DEFAULT_HOLDER)
	
	# 若 完全被釋放 則 從 預載表 中 移除
	if not res_info.is_alive() :
		self.id_to_prehold.erase(id)

# Preset ============

## 持有 配置
func prehold_preset (preset_path: String) -> bool :
	
	self._print("prehold_preset ===========")
	
	# 持有者
	var holder = self.get_preset_holder(preset_path)
	
	# 取得 依賴排序後 的 配置資訊
	var sorted_preset_infos = await self.get_sorted_preset_info(preset_path)
	# 若 無法取得 則 持有失敗
	if sorted_preset_infos == null : return false
	
	if self.is_debug :
		G.print("==sorted_preset_infos==")
		for info in sorted_preset_infos :
			G.print('preset "%s"' % info.path)
			G.print(info)
		G.print("=====================")
	
	# 每個 配置資訊
	for preset_info in sorted_preset_infos :
		
		# 若 有 資源設置
		if preset_info.has("resources") :
			var resources : Array = preset_info["resources"]
			
			# 建立 非同步行為
			var fn_list : Array[Callable] = []
			# 資源列表中 每個成員
			for each in resources :
				var path
				var options := {}
				
				var typ = typeof(each)
				match typ :
					# 若為 字串 則 視為 資源路徑
					TYPE_STRING :
						path = each
						
					# 若為 字典 則 視為 路徑與選項
					TYPE_DICTIONARY :
						path = each["path"]
						each.erase("path")
						options = each
					
				# 加入到非同步行為中
				fn_list.push_back(func(ctrlr):
					# 持有資源
					await self.hold(path, holder, options)
					ctrlr.next()
				)
			
			# 執行並等待 所有 非同步 持有資源
			await self.Util.async.parallel(fn_list)
		
	return true
	

## 釋放 預載配置
func unprehold_preset (preset_path: String) :
	# 試取得 為 檔案路徑
	var file_path = self.get_file_path_if_is(preset_path)
	if file_path != null : preset_path = file_path
	# 持有者
	var holder = self.get_preset_holder(preset_path)
	# 釋放 所有 該持有者的
	self.drop(null, holder)


## 蒐集 配置相關資訊 (回傳 路徑:資訊表)
func collect_preset_info (preset_path: String, path_to_info: Dictionary = {}, preset_path_to_file_path := {}) :
	
	# 試取得 為 檔案路徑
	var file_path = self.get_file_path_if_is(preset_path)
	if file_path != null : preset_path = file_path
	
	# 若 現有路徑:資訊表 已經 存在 該配置 則 返回
	if path_to_info.has(preset_path) : return path_to_info
	
	# 讀取 配置檔
	var preset_json : JSON = await self.built_in_loader.load_by_path(preset_path, "JSON")
	if preset_json == null : return null
	
	var preset : Dictionary = preset_json.data
	
	# 建立 資訊 為 副本
	var preset_info := preset.duplicate()
	
	# 設 路徑
	preset_info["path"] = preset_path
	
	# 轉換過 的 依賴列表
	var requires := []
	
	# 若 資訊 有 依賴列表
	var has_requires := preset_info.has("requires")
	if has_requires : 
		# 試取得並轉換 路徑 為 檔案路徑
		for path in preset_info["requires"] :
			var f_path = self.get_file_path_if_is(path)
			if f_path != null : path = f_path
			requires.push_back(path)
	
	# 取代 資訊的依賴列表 為 處理過的
	preset_info["requires"] = requires
	
	# 加入 路徑:資訊 表
	path_to_info[preset_path] = preset_info
	
	# 若 資訊 的 依賴列表 存在
	if has_requires :
		# 蒐集 每個 依賴相關資訊
		for each in requires :
			var each_res = await self.collect_preset_info(each, path_to_info, preset_path_to_file_path)
			if each_res == null :
				push_error("[URes] missing reqiure preset : %s" % each)
				return null
	
	return path_to_info

## 取得 排序後的 配置資訊
func get_sorted_preset_info (preset_path: String) :
	
	# 蒐集 配置相關資訊 (包含該配置的依賴, 以及依賴的依賴...等)
	var preset_path_to_info = await self.collect_preset_info(preset_path)
	if preset_path_to_info == null : return null
	
	# 下一個要檢查的佇列
	var queue := []
	
	# 已排序的結果
	var sorted_list := []
	
	# 路徑:依賴列表 表
	var preset_to_requires := {}
	for path in preset_path_to_info :
		var info : Dictionary = preset_path_to_info[path]
		var requires : Array = info["requires"].duplicate()
		if requires.size() > 0 :
			preset_to_requires[path] = requires
		else :
			queue.push_back(path)
	
	# 若 佇列中 還有
	while queue.size() > 0 :
		# 取出並加入 排序結果
		var target_path = queue.pop_front()
		sorted_list.push_back(target_path)
		
		# 若 依賴表中 有該路徑與該路徑的依賴 則
		if preset_to_requires.has(target_path) :
			# 移除
			preset_to_requires.erase(target_path)
		
		# 檢查 剩下的所有 其他路徑與依賴
		for left_path in preset_to_requires :
			
			# 剩下 的 其他路徑依賴
			var left_requires = preset_to_requires[left_path]
			
			# 移除 其他路徑 對 此路徑的依賴
			if left_requires.has(target_path) :
				left_requires.erase(target_path)
			
			# 若 已經沒有依賴尚未被排序 且 不在佇列中
			if left_requires.size() == 0 and not queue.has(target_path) :
				# 從 依賴關係表中 移除
				preset_to_requires.erase(left_path)
				# 加入 下一個檢查 佇列
				queue.push_back(left_path)
			
		
	# 佇列跑完後
	
	# 若 仍有 路徑與依賴 尚未處理
	if preset_to_requires.size() > 0 :
		# 則 只有可能是有 循環依賴 存在
		push_error("[URes] Cyclic dependencies exist, unable to perform linear sorting")
		push_error(preset_to_requires)
		return []
	
	var result := []
	for path in sorted_list :
		result.push_back(preset_path_to_info[path])
	
	return result

# Utility ===========

## 取得 檔案路徑 若為檔案路徑
func get_file_path_if_is (full_path: String) :
	
	# 從 快取 找
	if self.path_to_file_path.has(full_path) :
		return self.path_to_file_path[full_path]
	
	var file_path = null
	# 若有 檔案路徑 標示 則 取代
	if full_path.begins_with("file://") : 
		file_path = "./" + full_path.right(-7)
	# 若有 檔案路徑 元素 則 設 檔案路徑 為 完整路徑
	if full_path.begins_with(".") : 
		file_path = full_path
	
	# 開啟並重新確認檔案路徑
	#if path != null :
		#var file = FileAccess.open(path, FileAccess.READ)
		#if file != null :
			#path = file.get_path()
	
	# 若 是 檔案路徑
	if file_path != null :
		# 加入快取
		self.path_to_file_path[full_path] = file_path
	
	return file_path

## 建立 資源資訊 辨識
func make_res_info_id (full_path: String, loader_id: String) :
	if loader_id.is_empty() : 
		loader_id = "_"
	return "%s|%s" % [loader_id, full_path]

# Private ====================

## 取得 配置持有者
func get_preset_holder (preset_path: String) -> String :
	return "_preset:%s" % preset_path

## 偵錯
func _print (msg) :
	if self.is_debug : 
		G.print(msg)
