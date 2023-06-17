
## Math 數學相關
##
## 補完內建缺少的相關處理
## 

## 轉換 百分比 至 分貝
func percent_to_db (linear) -> float :
	if linear > 0 :
		return log(linear) * 20.0
	else :
		return -80
		

## 轉換 分貝 至 百分比
func db_to_percent (db) -> float :
	if db != 0 : 
		return pow(10.0, db / 20.0)
	else :
		return 1.0
