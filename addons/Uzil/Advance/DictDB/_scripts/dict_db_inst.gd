# Variable ===================

var DictDB

## 是否除錯
var is_debug : bool = false

## 資料資訊
var id_to_info : Dictionary = {}

## 資料快取
var id_to_cache_dict : Dictionary = {}

## 請求 資料資訊 繼承與覆寫 選項 ()
var _req_info_extends_opts : Dictionary = {"keys":["_extends", "_overrides"]}
## 融合資料 選項 (排除繼承覆寫相關)
var _merge_dicts_opts : Dictionary = {"without_keys":["_extends", "_override"]}

# GDScript ===================

func _init (_DictDB) :
	self.DictDB = _DictDB

# Extends ====================

# Interface ==================

# Public =====================

## 請求 資料
func req_dict (id: String, is_use_cache := true) :
	if not self.id_to_info.has(id) : return null
	
	# 若 使用快取 則 試取用
	if is_use_cache and self.id_to_cache_dict.has(id) :
		return self.id_to_cache_dict[id]
	
	var dict_util = UREQ.acc(&"Uzil:Util").dict
	
	# 資訊
	var info = self.id_to_info[id]
	# 取得 繼承與覆寫
	var to_extends_overrides : Array = self._req_info_extends(info, dict_util)
	
	# 組建資料
	var data : Dictionary = {}
	
	# 繼承 其他資料
	self._overwrite_dict(data, to_extends_overrides[0])
	
	#if self.is_debug :
		#G.print("extendeds %s :\n%s" % [to_extends, data])
	
	# 依序讀入 所有原始資料 成為 完整資料 (用merge方式去除融合格式)
	for each in info.raw_dicts :
		dict_util.merge_ex(data, each, self._merge_dicts_opts)
		
		#if self.is_debug :
			#G.print("merge raw :\n%s" % [each])
	
	# 覆寫 其他資料
	self._overwrite_dict(data, to_extends_overrides[1])
	
	#if self.is_debug :
		#G.print("final: %s" % [data])
	
	# 若 使用快取 則 紀錄
	if is_use_cache :
		self.id_to_cache_dict[id] = data
	
	return data

## 讀入 資料
func load_dict (id: String, dict: Dictionary) :
	# 相關資訊
	var info = null
	# 取 現有
	if self.id_to_info.has(id) :
		info = self.id_to_info[id]
	# 否則 新建
	else :
		info = self.DictDB.Info.new()
		info.id = id
		self.id_to_info[id] = info
	
	# 加入 原始資料 (不用去除融合格式)
	info.raw_dicts.push_back(dict)
	
	return info

## 讀入 資料 設定檔
func load_cfg (path: String) :
	var _id_to_dict = UREQ.acc(&"Uzil:Util").config.load_cfg_dict(path)
	if _id_to_dict == null : return null
	
	var result : Dictionary = {}
	
	var id_to_dict : Dictionary = _id_to_dict
	for id in id_to_dict :
		var info = self.load_dict(id, id_to_dict[id])
		result[id] = info
	
	return result

# Private ====================

## 覆寫 資料
func _overwrite_dict (data: Dictionary, to_extends: Array, _middle_data := {}) :
	
	# 字典工具
	var is_dict_util_exist : bool = _middle_data.has("dict_util")
	var dict_util = _middle_data["dict_util"] if is_dict_util_exist else UREQ.acc(&"Uzil:Util").dict
	if not is_dict_util_exist :
		_middle_data["dict_util"] = dict_util
	
	# 已經被處理的
	var is_handled_exist : bool = _middle_data.has("handled")
	var handled : Dictionary = _middle_data["handled"] if is_handled_exist else {}
	if not is_handled_exist :
		_middle_data["handled"] = handled
	
	# 每個 要被繼承的
	for each in to_extends :
		if not self.id_to_info.has(each) : continue
		
		# 取出 資訊
		var info = self.id_to_info[each]
		
		var info_extends_overrides = null
		
		# 若 尚未被處理
		if not handled.has(each) :
			handled[each] = true
			# 請求 繼承資訊
			info_extends_overrides = self._req_info_extends(info, dict_util)
			# 若 也存在繼承 則 遞迴繼承
			var info_extends : Array = info_extends_overrides[0]
			if info_extends.size() > 0 :
				self._overwrite_dict(data, info_extends, _middle_data)
		
		# 每個 原始資料 融入 主資料
		for each_raw in info.raw_dicts :
			dict_util.merge_ex(data, each_raw, self._merge_dicts_opts)
		
		# 若 覆寫 存在
		if info_extends_overrides != null :
			var info_overrides : Array = info_extends_overrides[1]
			if info_overrides.size() > 0 :
				# 覆寫
				self._overwrite_dict(data, info_overrides, _middle_data)
	

## 請求 資料資訊 的 繼承與覆寫相關
func _req_info_extends (info, dict_util) :
	# 融合 所有原始資料 (僅有必要key)
	var data := {}
	for each_raw in info.raw_dicts :
		dict_util.merge_ex(data, each_raw, self._req_info_extends_opts)
	# 取出 並 返回 繼承與覆寫
	var result := [[], []]
	if data.has("_extends") : 
		result[0] = data["_extends"]
	if data.has("_overrides") : 
		result[1] = data["_overrides"]
	return result
