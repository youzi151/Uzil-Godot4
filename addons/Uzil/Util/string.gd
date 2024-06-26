
## String 相關
##
## 補完內建String缺少的相關處理
## 

## 替換 限次數
func replace (str: String, search: String, to_replace: String, limit: int) -> String :
	var result : String = ""
	var count : int = 0
	
	while str.find(search) != -1 and count < limit :
		var index : int = str.find(search)
		result += str.substr(0, index) + to_replace
		str = str.substr(index + search.length())
		count += 1
		
	result += str
	
	return result
