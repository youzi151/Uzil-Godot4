
## RNG_Rate 比率隨機
##
## 可指定各數字的出現機率的隨機產生器
## 

## 隨機數字產生器
var rng

## 比例表
var _rates = []

## 比例總和
var _rate_total = 0

## 最小值
var _min = 0

## 最大值
var _max = 0

## 初始化
func _init () :
	self.rng = RandomNumberGenerator.new()

## 設置 機率表
func rates (rate_arr, _is_duplicate = true) :
	if _is_duplicate :
		self._rates = rate_arr.duplicate()
	else :
		self._rates = rate_arr
		
	self._resize_rates()
	
	# 比例加總 ==
	self._rate_total = 0
	for each in rate_arr :
		self._rate_total += each
		
	return self

## 設置 機率
func rate (idx, _rate) :
	if idx > self._rates.size() or idx < 0 : return
	self._rates[idx] = _rate
	return self

## 設置 機率均等
func equality () :
	for idx in range(0, self._rates.size()) :
		self._rates[idx] = 1
	return self

## 種子碼
func rngseed (_seed) :
	# 隨機 ======
	# 若 有種子碼 
	if _seed != null :
		# 準備 種子碼 為 數值
		var seeed
		if typeof(_seed) == TYPE_STRING :
			seeed = hash(_seed)
		else :
			seeed = _seed
			
		# 設置 種子碼
		self.rng.seed = seeed
	# 若 無
	else :
		# 隨機
		self.rng.randomize()
	
	return self

## 設置 範圍
func minmax (min, max) :
	# 防呆
	if min > max :
		var tmp = max
		max = min
		min = tmp
	
	# 設置 最小最大值
	self._min = min
	self._max = max

	self._resize_rates()
	
	return self

## 產生隨機數
func gen () :
	var rate_size = self._rates.size()

	if rate_size <= 1 : return 0

	# 產生隨機====
	
	# 在 總比例數 中 隨機取得數字
	var rng_num = self.rng.randi_range(1, self._rate_total)

	# 在 比例 中 遞減 直到耗盡 選出 該比例的 序號 -> 
	for idx in range(0, rate_size) :
		rng_num -= self._rates[idx]
		if rng_num <= 0 : return self._min + idx

	return null

## 重新調整 比率表 大小
func _resize_rates () :
	# 目標範圍
	var range_size = self._max - self._min
	
	# 目標範圍 與 目前比例數量的 差距
	var delta = range_size - self._rates.size()
	
	# 補足 或 削減
	if delta > 0 :
		for idx in range(0, delta) :
			self._rates.push_back(1)
	elif delta < 0 :
		self._rates.resize(range_size)

