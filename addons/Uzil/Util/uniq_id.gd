
## UniqID 唯一識別相關
## 
## 自動加入後綴數字, 並透過自訂檢查函式 來 確認不重複.
## 

## 修補
func fix (id : String, is_pass_fn : Callable) :
	var suffix = ""
	var i = 0
	while not is_pass_fn.call(id + suffix) :
		i += 1
		suffix = "_" + str(i)
	return id + suffix
