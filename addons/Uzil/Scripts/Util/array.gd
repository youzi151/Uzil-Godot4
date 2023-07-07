
## Array相關
##
## 處理 Array 的 相關事務
## 

func map (arr : Array, fn : Callable) -> Array :
	var result := []
	for idx in range(arr.size()) :
		var new_val = fn.call(idx, arr[idx])
		result.push_back(new_val);
	return result

func filter (arr : Array, fn : Callable) -> Array :
	var result := []
	for idx in range(arr.size()) :
		var val = arr[idx]
		if fn.call(idx, val) == true :
			result.push_back(val)
	return result
