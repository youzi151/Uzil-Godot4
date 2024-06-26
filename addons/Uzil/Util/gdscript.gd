
## GDScript相關
##
## 處理或查詢 GDScript 的 相關事務
## 

## 是否為GDScript
func is_gdscript (target) :
	if target == null : return false
	if target is String : return false
	return target.get_class() == "GDScript"

## 是否繼承自
func is_extends_of (target_script, parent_script) :
	if target_script == null or parent_script == null : return false
	if self.is_gdscript(target_script) == false :
		target_script = target_script.get_script()
	if self.is_gdscript(parent_script) == false :
		parent_script = parent_script.get_script()
	
	if target_script == parent_script : 
		return true
	
	var base_script = target_script.get_base_script()
	
	var try_times = 100
	while base_script != null and try_times > 0:
		
		if base_script == parent_script :
			return true
			
		base_script = base_script.get_base_script()
		
		try_times -= 1
		
	return false

## 取得 繼承鏈
func get_extends_tree (target_script) :
	
	var tree = [target_script]
	
	var base_script = target_script.get_base_script()
	
	var try_times = 100
	while base_script != null and try_times > 0:
		tree.push_back(base_script)
		base_script = base_script.get_base_script()
		try_times -= 1
		
	return tree

## 以 名稱或路徑 取得 字典中的 腳本
func get_script_from_dict (dict, name_or_path) :
	
	# 若 本來就是腳本了
	if self.is_gdscript(name_or_path):
		return name_or_path 
	
	var Uzil = UREQ.acc(&"Uzil:Uzil")
	
	var script
	
	# 若 有註冊 則 先試著 以 名稱 取得路徑 來 讀取
	if dict.has(name_or_path) :
		var path_or_script = dict[name_or_path]
		var typ = typeof(path_or_script)
		if typ == TYPE_STRING :
			script = Uzil.load_script(path_or_script)
		elif self.is_gdscript(path_or_script) :
			script = path_or_script
	
	# 若 腳本 不存在 則 以路徑讀取
	if script == null :
		script = Uzil.load_script(name_or_path)
	
	# 若 仍無法取得 則 返回
	if script == null : 
		return null
		
	# 若 資源類型 不為 腳本 則 返回
	if script.get_class() != "GDScript" :
		return null
		
	return script
