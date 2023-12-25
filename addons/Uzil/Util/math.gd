
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

## 尋找 cubic_bezier 的 weight
func cubic_bezier_find_weight (p0: float, p3: float, p1: float, p2: float, val: float, deviation: float, iteration: int = -1) -> float :
	if iteration == -1 : 
		iteration = ceil(ceil(log((p3-p0) / deviation)) / log(2.0))
	
	if val == 0.0 : return 0.0
	if val == 1.0 : return 1.0
	
	var weight := 0.5
	var tweak := (weight * 0.5)
	
	for idx in range(iteration) :
		var test_val := cubic_interpolate(p0, p3, p1, p2, weight)
#		print("[%s]-%s to %s-[%s] = weight[%s] test[%s] target[%s] " % [p0, p1, p2, p3, weight, test_val, val])
		if test_val == val : return weight
		if abs(test_val - val) < deviation : return weight
			
		tweak *= 0.5
		if test_val > val :
			weight -= tweak
		else :
			weight += tweak
		
	return weight
	
	
	
