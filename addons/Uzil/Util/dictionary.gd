
## Dictionary相關
##
## 處理 Dictionary 的 相關事務
## 

func map (dict: Dictionary, fn: Callable) -> Dictionary :
	var result := {}
	for key in dict :
		var new_val = fn.call(key, dict[key])
		result[key] = new_val
	return result

func filter (dict: Dictionary, fn: Callable) -> Dictionary :
	var result := {}
	for key in dict :
		var val = dict[key]
		if fn.call(key, val) == true :
			result[key] = val
	return result

func get_from_dicts (key: String, dicts: Array, default_res = null) :
	for each in dicts :
		if each.has(key) :
			return each[key]
	return default_res

func get_from_dict (key: String, dict: Dictionary, default_res = null) :
	if dict.has(key) : return dict[key]
	return default_res
