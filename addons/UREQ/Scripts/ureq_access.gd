## UREQ.Access 模塊存取
##
## 綁定 存取 目標物件/取得方法 的 模塊資料.
##

# Variable ===================

## 辨識
var id := ""
## 所屬域 (檢查判斷用)
var scope := ""
## 路徑 (檢查判斷用, 格式為 "scope/id")
var path := ""
## 別名
var alias := []

## 是否屬於非同步載入
var is_async := false

## 存取目標
var target = null
## 是否忽略快取
var is_ignore_cached := false

## 腳本路徑
var script_path := ""
## 目標腳本
var target_script : GDScript = null
## 是否忽略快取腳本
var is_ignore_cached_script := false

## 建立目標的函式
var create_target_fn = null

## 依賴的其他模塊 
## (可為 Array(id_or_alias_list) / Dictionary(scope_key:id_or_alias_list))
var requires = []

## 是否依賴的其他模塊已經被檢查過
var is_requires_checked := false

## 其他選項
var options := {}

# GDScript ===================

func _to_string () :
	return str({
		"id": self.id, "reqires": self.requires
	})

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

