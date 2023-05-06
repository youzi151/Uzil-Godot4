
## ObjPool.Shell 物件池 殼
##
## 具有基本的物件池功能 [br]
## 使用 可替換的核心 來進行 建立/銷毀/與實際物件溝通的行為
##

# Variable ===================

## 核心
var core

## 容量 [br]
## 可取用超過容量數量的物件, 回收時若已達池物件最大容量則該回收物件會銷毀而非回收至池中
var _size : int = 0

## 物件池
var _pool : Array = []

## 使用中的物件
var _used : Array = []

# Public =====================

## 設置 核心
func set_core (_core) :
	self.core = _core
	return self

## 設置 容量
func set_size (_max) :
	self._size = _max
	return self

## 重用
func reuse () :
	var new_one
	# 若 物件池 中 已空 則 建立
	if self._pool.size() == 0 :
		new_one = self.core.create()
	# 否則 取用
	else :
		new_one = self._pool.pop_back()
		
	# 初始化 物件
	self.core.initial(new_one)
	
	return new_one

## 回收
func recovery (old_one) :
	# 若 該回收物件 在 使用中 則
	if self._used.has(old_one) :
		# 從使用中移除
		self._used.erase(old_one)
	
	# 反初始化
	self.core.uninitial(old_one)
	
	# 若 物件池 容量 未達 上限
	if self._pool.size() < self._size :
		# 加入 物件池
		self._pool.push_back(old_one)
	# 若已達上限 則
	else :
		# 銷毀
		self.core.destroy(old_one)

## 重置容量
func resize () :
	# 當前容量
	var size := self._pool.size()
	# 目標容量
	var to_size := self._size
	# 差距
	var delta := to_size - size
	
	# 若 沒有差距 則 返回
	if delta == 0 :
		return self
	
	# 若 需要補足 則
	elif delta > 0 :
		# 建立並加入物件池
		for idx in range(size, to_size) :
			var new_one = self.core.create()
			self._pool.push_back(new_one)
	
	# 若 超過 則
	elif delta < 0 :
		# 加入 預計要銷毀的
		var to_destroy = []
		print("%s to %s delta %s" % [size, to_size, delta])
		for idx in range(to_size, size) :
			to_destroy.push_back(self._pool[idx])
		
		# 設置容量
		self._pool.resize(to_size)
		
		# 實際銷毀
		for each in to_destroy :
			self.core.destroy(each)
		
	return self

# Private ====================

# core 對應 #####

### 建立
#func create () :
#	return null
#
### 銷毀
#func destroy (_target) :
#	pass
#
### 初始化
#func initial (_new_one) :
#	pass
#
### 反初始化
#func uninitial (_old_one) :
#	pass
