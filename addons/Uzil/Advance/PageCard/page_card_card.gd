
## PageCard.Card 頁面卡 卡片
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

# Variable ===================

## 辨識
var id : String = "" 

## 標籤
var tags : Array[String] = []

## 目標物件
var targets : Array[Node] = []

## 是否啟用
var _is_active := true

## 其他資料
var data := {}

# GDScript ===================

# Public =====================

## 啟用
func active (_options := {}, is_force := false) :
	if not is_force and self._is_active : return
	
	self._is_active = true
	#G.print("%s : %s" % [self.id, self._is_active])
	
	await self.active_targets(_options)

## 關閉
func deactive (_options := {}, is_force := false) :
	if not is_force and not self._is_active : return
	
	self._is_active = false
	#G.print("%s : %s" % [self.id, self._is_active])
	
	await self.deactive_targets(_options)

## 啟用目標
func active_targets (_options := {}) :
	var async = UREQ.acc(&"Uzil:Util").async
	await async.each(self.targets, func(idx, each, ctrlr) :
		if is_instance_valid(each) : 
			if each.has_method("card_active") :
				await each.card_active(_options)
			else :
				each.visible = true
				each.process_mode = Node.PROCESS_MODE_INHERIT
		ctrlr.next()
	)


## 關閉目標
func deactive_targets (_options := {}) :
	var async = UREQ.acc(&"Uzil:Util").async
	await async.each(self.targets, func(idx, each, ctrlr) :
		if is_instance_valid(each) : 
			if each.has_method("card_deactive") :
				await each.card_deactive(_options)
			else :
				each.visible = false
				each.process_mode = Node.PROCESS_MODE_DISABLED
		ctrlr.next()
	)

# Private ====================
