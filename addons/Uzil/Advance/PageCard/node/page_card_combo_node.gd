extends Node

## PageCard.Combo 頁面卡 組合
## 
## 紀錄 辨識ID與查詢字串
## 

# Variable ===================

## 辨識
@export var id : String = ""

## 查詢字串
@export var query_str : String = ""


# GDScript ===================

# Public =====================

func request_combo () :
	var combo_data := {
		"id" : self.id,
		"query_str" : self.query_str,
	}
	
	if self.id == "" :
		combo_data.id = self.name
	
	return combo_data
	
	

# Private ====================
