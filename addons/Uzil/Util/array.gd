
## Array相關
##
## 處理 Array 的 相關事務
## 

func map (arr: Array, fn: Callable) -> Array :
	var result := []
	for idx in range(arr.size()) :
		var new_val = fn.call(idx, arr[idx])
		result.push_back(new_val);
	return result

func filter (arr: Array, fn: Callable) -> Array :
	var result := []
	for idx in range(arr.size()) :
		var val = arr[idx]
		if fn.call(idx, val) == true :
			result.push_back(val)
	return result

func is_intersects (arr1: Array, arr2: Array) -> bool :
	for v in arr1 :
		if arr2.has(v) :
			return true
	return false

func is_contains (arr1: Array, arr2: Array) -> bool :
	var is_match_any : bool = false
	for v in arr2 :
		if not arr1.has(v) :
			return false
		else :
			is_match_any = true
	return is_match_any
