extends Node

## UREQ 依賴管理
##
## 提供 依賴模塊 設置 存取該模塊目標的方式. 類似 Service Locator 用途與概念. [br]
## 透過 統一方法 存取 模塊, 並 將該模塊有相依關係的依賴模塊一並確保可存取. [br]
## 可用 異步方式 存取 需要下載 或 無法同步取得 的 模塊或其依賴模塊.
##

# Variable ===================

const ROOT_PATH := "res://addons/UREQ"
const PATH = ROOT_PATH + "/scripts"

## 模塊存取
var Access = null
## 所屬域
var Scope = null
## 存取任務
var Task = null

## 鍵:所屬域 表
var key_to_scope := {}

# GDScript ===================

func _init () :
	# 移除先前的
	if G.v.has("UREQ") :
		if is_instance_valid(G.v.UREQ) :
			var g_node : Node = G.v.UREQ
			g_node.get_parent().remove_child(g_node)
			g_node.free()
	
	# 設置 為 全域G變數 UREQ
	G.set_global("UREQ", self)
	
	self.Access = G.load_script(self.PATH.path_join("ureq_access.gd"))
	self.Scope = G.load_script(self.PATH.path_join("ureq_scope.gd"))
	self.Task = G.load_script(self.PATH.path_join("ureq_task.gd"))

# Extends ====================

# Interface ==================

# Public =====================

## 存取 (全域) access
func gacc (id: String) :
	return self.scope().access(id)

## 存取 (全域) access
func gaccync (id: String) :
	return await self.scope().accync(id)

## 存取 (指定 所屬域) access
func acc (key: String, id: String) :
	return self.scope(key).access(id)

## 存取 (指定 所屬域) access
func accync (key: String, id: String) :
	return await self.scope(key).accync(id)

## 綁定 (全域)
func gbind (id: String, inst, options := {}) :
	return self.scope().bind(id, inst, options)

## 綁定 (指定 所屬域)
func bind (key: String, id: String, inst, options := {}) :
	self.scope(key).bind(id, inst, options)

## 取得 所屬域
func scope (key: String = "") :
	if self.key_to_scope.has(key) :
		return self.key_to_scope[key]
	
	var scope = self.Scope.new(key, self)
	self.key_to_scope[key] = scope
	return scope


## 排序模塊 以依賴關係
func get_sort_require_list (_accesses: Array) -> Array :
	## 卡恩演算法
	
	# 下一個要檢查的佇列
	var queue := []
	# 已排序的結果
	var sorted_access_list := []
	# 模塊:依賴列表 表
	var access_to_dependencies := {}
	# 路徑:模塊 表
	var path_to_access := {}
	
	# 每個 模塊
	for access in _accesses :
		# 的 所需依賴表
		var dependency := {}
		# 蒐集 所需依賴 資訊
		var scope_to_requires = self.requires_to_dict(access.scope, access.requires)
		
		# 若 不在 路徑:模塊表 則 加入
		if not path_to_access.has(access.path) :
			path_to_access[access.path] = access
		
		# 每個 所需依賴
		# 所屬域
		for scope_key in scope_to_requires :
			var scope = self.scope(scope_key)
			# 的 每個依賴
			var scope_requires = scope_to_requires[scope_key]
			for req_id_or_alias in scope_requires :
				var req_access = scope.get_access(req_id_or_alias)
				
				# 若 不在 所需依賴表 則 加入
				if not dependency.has(req_access.path) :
					dependency[req_access.path] = true
				
				# 若 不在 路徑:模塊表 則 加入
				if not path_to_access.has(req_access.path) :
					path_to_access[req_access.path] = req_access
		
		# 加入 該模塊:所需依賴 表
		var dependencies = dependency.keys()
		access_to_dependencies[access.path] = dependencies
		
		# 若 沒有所需依賴 則 加入 該模塊 至 佇列
		if access.requires.size() == 0 :
			queue.push_back(access)
		
	# 若 佇列中 還有
	while queue.size() > 0 :
		# 取出並加入 排序結果
		var access = queue.pop_front()
		sorted_access_list.push_back(access)
		
		# 若 依賴表中 有該模塊路徑與該模塊的依賴 則
		if access_to_dependencies.has(access.path) :
			# 移除
			access_to_dependencies.erase(access.path)
			
		# 檢查 剩下的所有 其他模塊與依賴
		for each_path in access_to_dependencies :
			# 剩下 的 其他模塊依賴
			var each_access_requires = access_to_dependencies[each_path]
			
			# 移除 其他模塊 對 此模塊的依賴
			if each_access_requires.has(access.path) :
				each_access_requires.erase(access.path)
			
			# 其他模塊
			var each_access = path_to_access[each_path]
			
			# 若 已經沒有依賴尚未被排序 且 不在佇列中
			if each_access_requires.size() == 0 and not queue.has(each_access) :
				# 從 依賴關係表中 移除
				access_to_dependencies.erase(each_path)
				# 加入 下一個檢查 佇列
				queue.push_back(each_access)
			
		
	# 佇列跑完後
	
	# 若 仍有 模塊與依賴 尚未處理
	if access_to_dependencies.size() > 0 :
		# 則 只有可能是有 循環依賴 存在
		push_error("Cyclic dependencies exist, unable to perform linear sorting")
		push_error(access_to_dependencies)
	
	# 回傳 排序結果
	return sorted_access_list


## 蒐集 依賴資訊 (回傳 路徑:Access表)
func collect_requires (requires: Dictionary, collected := {}) -> Dictionary :
	# 每個 在依賴中 的 所屬域
	for scope_key in requires :
		# 所屬域
		var scope = self.scope(scope_key)
		# 依賴列表
		var list = requires[scope_key]
		
		# 每個依賴列表
		for each_id_or_alias in list :
			# 取得 模塊
			var each_access = scope.get_access(each_id_or_alias)
			# 若 無 則 忽略
			if each_access == null : continue
			
			# 若 已被加入 則 忽略
			if collected.has(each_access.path) : continue
			
			# 若 該存取 尚未被檢查過依賴
			if not each_access.is_requires_checked :
				# 加入
				collected[each_access.path] = each_access	
				# 把 依賴列表 轉換為 所屬域:依賴列表 表
				var each_requires = self.requires_to_dict(scope.key(), each_access.requires)
				# 遞迴蒐集
				self.collect_requires(each_requires, collected)
			
		
	
	return collected

## 把 依賴列表 轉換為 所屬域:依賴列表 表
func requires_to_dict (default_scope: String, requires) -> Dictionary :
	
	var scope_to_requires : Dictionary
	
	var type_requires = typeof(requires)
	if type_requires == TYPE_ARRAY :
		scope_to_requires = { default_scope : requires }
	elif type_requires == TYPE_DICTIONARY :
		scope_to_requires = requires
		
	return scope_to_requires

## 取得 模塊路徑 (辨識用, 所屬域/id)
func get_access_path (scope: String, id: String) -> String :
	return "%s/%s" % [scope, id]

## 讀取腳本
func load_script (path: String, is_reload: bool = false) :
	return G.load_script(path, is_reload)

# Private ====================
