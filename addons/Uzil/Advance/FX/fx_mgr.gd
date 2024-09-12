
## FX.Mgr 特效 管理
##
## 提供簡易對特效物件的物件池相關使用.
##

## 特效資訊
class FXInfo :
	var id : String
	var pool : RefCounted
	func _init (_id: String, _pool: RefCounted) :
		self.id = _id
		self.pool = _pool

# Variable ===================

## ID:實例 表
var _id_to_inst : Dictionary = {}

## 實例:資訊 表
var _inst_to_info : Dictionary = {}

## 來源:池 表
var _src_to_pool : Dictionary = {}

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 取得 特效
func get_fx (id: String) :
	if not self._id_to_inst.has(id) : return null
	return self._id_to_inst[id] 

## 準備 特效
func prepare (src: String, size: int) :
	var pool : RefCounted = await self._req_pool(src)
	if pool == null : return
	pool.resize(size)

## 重用 特效
func reuse (prefer_id: String, src: String, init_data: Dictionary = {}) :
	var pool : RefCounted = await self._req_pool(src)
	if pool == null : return
	
	# 取得 不重複ID
	var id : String = UREQ.acc(&"Uzil:Util").uniq_id.fix(prefer_id, func(new_id) :
		return not self._id_to_inst.has(new_id)
	)
	
	# 從 物件池 重用
	var fx_node : Node = pool.reuse(init_data)
	fx_node.name = id
	
	# 註冊
	self._id_to_inst[id] = fx_node
	self._inst_to_info[fx_node] = FXInfo.new(id, pool)
	
	return fx_node

## 回收 特效
func recovery (fx_node: Node) :
	if not self._inst_to_info.has(fx_node) : return
	var info : FXInfo = self._inst_to_info[fx_node]
	# 註銷
	self._inst_to_info.erase(fx_node)
	self._id_to_inst.erase(info.id)
	# 回收
	info.pool.recovery(fx_node)

## 清除 特效
func clear (is_clear_src_to_pool := false) :
	for each in self._inst_to_info :
		var info : FXInfo = self._inst_to_info[each]
		info.pool.recovery(each)
	self._inst_to_info.clear()
	self._id_to_inst.clear()
	
	if is_clear_src_to_pool :
		self._src_to_pool.clear()

# Private ====================

## 請求 物件池
func _req_pool (src: String) :
	var pool : RefCounted = null
	if self._src_to_pool.has(src) :
		
		pool = self._src_to_pool[src]
		
	else :
		
		# 設置 預製物件
		var res = UREQ.acc(&"Uzil:res")
		var res_info = await res.hold(src)
		if res_info == null : return null
		
		var ObjPool = UREQ.acc(&"Uzil:Core.ObjPool")
		pool = ObjPool.Strat_Prefab.new_core()
		self._src_to_pool[src] = pool
		
		var prefab : PackedScene = res_info.res
		pool.strat.set_prefab(prefab)
		
		# 設置 初始化 方法
		pool.strat.set_init(func(one, data):
			if one.has_method("_fx_init") :
				one._fx_init(self, data)
		)
		
		# 設置 反初始化 方法
		pool.strat.set_uninit(func(one):
			if one.has_method("_fx_uninit") :
				one._fx_uninit(self)
		)
		
	return pool
