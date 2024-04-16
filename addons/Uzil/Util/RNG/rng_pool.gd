
## RNG_Pool池隨機
##
## 提供一個以特定規則循環，確保出現頻率平衡的假隨機
## 

## 循環類型
enum LoopType {
	RATE,   ## 全部抽完一輪後, 每個數的出現次數必定按照比例, 直到池中只剩一個序號時才會重複抽出
	SINGLE, ## 每個數只會抽出一次, 照機率比例隨機抽出, 不會重複抽出
}

# 隨機類型
var _loop_type := LoopType.RATE

# 比例隨機產生器
var _rng_rate = null

# 機率比例
var _rates := []

# 隨機池
var _pool := {}

# 最小值
var _min := 0

# 最大值
var _max := 0

# 種子碼
var _rng_seed = null

# 目前的結果
var _peeked_idx = null

# 最後一次的結果
var _last_res = null

# 初始化
func _init () :
	var RNG = UREQ.acc("Uzil", "RNG")
	self._rng_rate = RNG.Rate.new()

# 設置 機率表
func rates (rate_arr) :
	self._rates = rate_arr.duplicate()
	self._resize_rates()
	return self

# 設置 機率
func rate (idx, _rate) :
	if idx > self._rates.size() or idx < 0 : return
	self._rates[idx] = _rate
	return self

# 設置 機率均等
func equality () :
	for idx in range(0, self._rates.size()) :
		self._rates[idx] = 1
	return self

# 設置 種子碼
func rngseed (_seed = null) :
	self._rng_seed = _seed
	return self

# 設置 範圍
func size (_size) :
	# 防呆
	if _size < 0 :
		_size = 0
	
	# 設置 最小最大值
	self._min = 0
	self._max = _size - 1

	self._resize_rates()
	
	return self

# 設置 範圍
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

# 設置 循環類型
func loop (typ) :
	self._loop_type = typ
	self.reset()
	return self

# 重設
func reset () :
	self._pool.clear()
	
	match self._loop_type :
		LoopType.RATE :
			for idx in range(0, self._rates.size()) :
				self._pool[idx] = self._rates[idx]
		LoopType.SINGLE, _ :
			for idx in range(0, self._rates.size()) :
				self._pool[idx] = 1
		
	return self

# 取出下一個
func next () :
	var res = self.peek()
	
	if self._peeked_idx == null : return res
	
	# 從池中移除
	var left_count = self._pool[self._peeked_idx]
	left_count -= 1
	if left_count <= 0 :
		self._pool.erase(self._peeked_idx)
	else :
		self._pool[self._peeked_idx] = left_count
	
	# 移除 當前暫存	
	self._peeked_idx = null
	
	# 存為前次結果
	self._last_res = res
	
	# 重新產生
	self.peek()
	
	return res

# 查看下一個
func peek () :
	if self._peeked_idx == null :
		self._peeked_idx = self._gen_idx()
	if self._peeked_idx == null :
		return null
	return self._get_res(self._peeked_idx)

# 產生隨機
func _gen_idx () :

	var seed = self._rng_seed
	
	var pool_size = self._pool.size()
	
	if pool_size == 0 :
		self.reset()
		pool_size = self._pool.size()

	var target_idx

	match pool_size :
		0 : 
			return null
		1 :
			target_idx = self._pool.keys()[0]
		_ :
			# 所有的序號
			var pooled_idxs = self._pool.keys()
			# 序號對應的比例
			var pooled_rates = []
			for each in pooled_idxs :
				pooled_rates.push_back(self._rates[each])
			
			# 設置 比例隨機
			self._rng_rate.rates(pooled_rates, false).rngseed(seed)
			
			# 以 隨機數 取得 pool中的序號
			target_idx = pooled_idxs[self._rng_rate.gen()]
			
			# 若 計算為結果 後 與 上次結果相同
			if self._get_res(target_idx) == self._last_res :
				
				# 記錄此次序號
				var last_target_idx = target_idx
				
				# 重新以 隨機數 取得 pool中的序號
				target_idx = pooled_idxs[self._rng_rate.rngseed(self._get_offseted_seed(seed)).gen()]
				
				while target_idx == last_target_idx :
					# 重新以 隨機數 取得 pool中的序號
					target_idx = pooled_idxs[self._rng_rate.rngseed(self._get_offseted_seed(seed)).gen()]
					
				# 復原 種子碼
				if seed != null :
					self._rng_rate.rngseed(seed)
			
#	print("gen %s" % target_idx)
	return target_idx


func _get_res (idx) :
	return self._min + idx

func _get_offseted_seed (seed) :
	if seed == null : return null
	else : return seed + 1

# 重新調整 比率表 大小
func _resize_rates () :
	# 目標範圍
	var range_size = self._max - self._min + 1
	
	# 目標範圍 與 目前比例數量的 差距
	var delta : int = range_size - self._rates.size()
	
	# 補足 或 削減
	if delta == 0 :
		return
	elif delta > 0 :
		for idx in range(0, delta) :
			self._rates.push_back(1)
	elif delta < 0 :
		self._rates.resize(range_size)
