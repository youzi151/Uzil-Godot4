
## Math 數學相關
##
## 補完內建缺少的相關處理
## 

## 轉換 百分比 至 分貝
func percent_to_db (linear: float) -> float :
	if linear > 0 :
		return log(linear) * 20.0
	else :
		return -80
		

## 轉換 分貝 至 百分比
func db_to_percent (db: float) -> float :
	if db != 0 : 
		return pow(10.0, db / 20.0)
	else :
		return 1.0

## 尋找 bezier 某值 的 weight
func bezier_find_weight (p0: float, p1: float, p2: float, p3: float, val: float, deviation: float, iteration: int = -1) -> float :
	if iteration == -1 : 
		var diff : float = p3 - p0
		if diff <= 0 : return 0
		iteration = ceil(ceil(log(diff / deviation) / log(2.0)))
	
	if val == p0 : return 0.0
	if val == p3 : return 1.0
	
	var weight := 0.5
	var tweak := weight * 0.5
	
	for idx in iteration :
		var test_val := bezier_interpolate(p0, p1, p2, p3, weight)
		#G.print("[%s]-%s to %s-[%s] = weight[%s] test[%s] target[%s] " % [p0, p1, p2, p3, weight, test_val, val])
		if test_val == val : return weight
		if abs(test_val - val) < deviation : return weight
		
		if idx+1 == iteration : return weight
		
		if test_val > val :
			weight -= tweak
		else :
			weight += tweak
		tweak *= 0.5
	
	return weight

