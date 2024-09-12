
## RNG_Rate 比率隨機
##
## 可指定各數字的出現機率的隨機產生器.
## 若比例為負數, 則為補足比例.
## 補足比例可用在當 其他正數的有效比例越多時, 越降低補足比例的數值.
## 

## 隨機數字產生器
var rng

## 比例表
var _rates := []

## 比例總和
var _rate_total := 0
## 有效的比例
var _rate_valid := 0

## 最小值
var _min := 0
## 最大值
var _max := 0

## 初始化
func _init () :
	self.rng = RandomNumberGenerator.new()

## 設置 機率表
func rates (rate_arr: Array, _is_duplicate := true) :
	if _is_duplicate :
		self._rates = rate_arr.duplicate()
	else :
		self._rates = rate_arr
		
	self._update_rates()
	return self

## 設置 機率
func rate (idx: int, _rate: int) :
	if idx > self._rates.size() or idx < 0 : return self
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
func minmax (min: int, max: int) :
	# 防呆
	if min > max :
		var tmp = max
		max = min
		min = tmp
	
	# 設置 最小最大值
	self._min = min
	self._max = max
	
	self._update_rates()
	
	return self

## 產生隨機數
func gen () -> int :
	var rate_size : int = self._rates.size()
	if rate_size == 0 : return -1
	if rate_size == 1 : return 0
	
	# 產生隨機====
	# 在 總比例數 中 隨機取得數字
	var rng_num : int = self.rng.randi_range(1, self._rate_total)
	
	# 在 比例 中 遞減 直到耗盡 選出 該比例的 序號 -> 
	for idx in range(0, rate_size) :
		var each : int = self._rates[idx]
		# 若為 負數 則 代表為 減去 有效的比例 的 補足比例
		if each < 0 :
			each = (-each) - self._rate_valid
		# 若 比例仍無效 則 忽略
		if each <= 0 : continue
		
		# 若 隨機數扣除比例後為0 則 
		rng_num -= each
		if rng_num <= 0 : return self._min + idx
	
	return -1

## 取得 大小
func size () -> int :
	return self._max - self._min

## 更新 比率表
func _update_rates () :
	
	# 目標範圍
	var range_size : int = self._max - self._min + 1
	
	# 目標範圍 與 目前比例數量的 差距
	var delta : int = range_size - self._rates.size()
	if delta < 0 :
		delta = 0
	
	# 補足 或 削減
	if delta > 0 :
		for idx in range(0, delta) :
			self._rates.push_back(1)
	elif delta < 0 :
		self._rates.resize(range_size)
	
	# 比例加總
	var neg_idxs := []
	
	self._rate_total = 0
	for idx in self._rates.size() :
		var each : int = self._rates[idx]
		if each == 0 :
			pass
		elif each > 0 :
			self._rate_total += each
			self._rate_valid += each
		else :
			neg_idxs.push_back(idx)
	for idx in neg_idxs :
		var each : int = self._rates[idx]
		each = (-each) - self._rate_valid
		if each > 0 :
			self._rate_total += each
