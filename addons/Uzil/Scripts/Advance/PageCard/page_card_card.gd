
## PageCard.Card 頁面卡 卡片
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

# Variable ===================

## 辨識 (若 留空 則 取node.name)
var id : String = "" 

## 標籤
var tags : Array[String] = []

## 目標物件
var targets : Array[Node] = []

## 是否啟用
var is_active := true

## 其他資料
var data := {}

# GDScript ===================

func _init () :
	pass	

func _process (_dt) :
	pass

# Public =====================

## 起始設置
func setup () :
	for each in self.targets :
		if not "visible" in each : continue
		if each.visible == false :
			self.is_active = false

## 啟用
func active (is_force := false) :
	if not is_force and self.is_active : return
	
	self.is_active = true
	
	for each in self.targets :
		if not is_instance_valid(each) : return
		
		if "visible" in each :
			each.visible = true
			
		each.process_mode = Node.PROCESS_MODE_INHERIT

## 關閉
func deactive (is_force := false) :
	if not is_force and not self.is_active : return
	
	self.is_active = false
	
	for each in self.targets :
		if not is_instance_valid(each) : return
		
		if "visible" in each :
			each.visible = false
		
		each.process_mode = Node.PROCESS_MODE_DISABLED

# Private ====================
