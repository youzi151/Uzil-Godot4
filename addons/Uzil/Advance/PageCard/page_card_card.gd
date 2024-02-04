
## PageCard.Card 頁面卡 卡片
## 
## 設置 目標物件 以及 控制 目標物件 的 顯示/隱藏, 執行/暫停(process)
## 

## 啟用模式
enum ActiveMode {
	# 顯示
	VISIBLE,
	# 呼叫
	CALL,
}

# Variable ===================

## 辨識
var id : String = "" 

## 標籤
var tags : Array[String] = []

## 目標物件
var targets : Array[Node] = []

## 啟用模式
var _active_mode : ActiveMode = ActiveMode.VISIBLE

## 是否啟用
var _is_active := true

## 其他資料
var data := {}

# GDScript ===================

func _init () :
	pass

func _process (_dt) :
	pass

# Public =====================

## 設置 啟用模式
func set_active_mode (active_mode : int) :
	self._active_mode = active_mode

## 啟用
func active (is_force := false) :
	if not is_force and self._is_active : return
	
	self._is_active = true
	#G.print("%s : %s" % [self.id, self._is_active])
	
	await self.active_targets()

## 關閉
func deactive (is_force := false) :
	if not is_force and not self._is_active : return
	
	self._is_active = false
	#G.print("%s : %s" % [self.id, self._is_active])
	
	await self.deactive_targets()

## 啟用目標
func active_targets () :
	match self._active_mode :
		
		ActiveMode.VISIBLE :
			for each in self.targets :
				if not is_instance_valid(each) : return
				if "visible" in each :
					each.visible = true
				each.process_mode = Node.PROCESS_MODE_INHERIT
		
		ActiveMode.CALL :
			var async = UREQ.acc("Uzil", "Util").async
			await async.each(self.targets, func(idx, each, ctrlr) :
				if is_instance_valid(each) : 
					await each.card_active()
				ctrlr.next.call()
			)

## 關閉目標
func deactive_targets () :
	match self._active_mode :
		
		ActiveMode.VISIBLE :
			for each in self.targets :
				if not is_instance_valid(each) : return
				if "visible" in each :
					each.visible = false
				each.process_mode = Node.PROCESS_MODE_DISABLED
		
		ActiveMode.CALL :
			var async = UREQ.acc("Uzil", "Util").async
			await async.each(self.targets, func(idx, each, ctrlr) :
				if is_instance_valid(each) : 
					await each.card_deactive()
				ctrlr.next.call()
			)
	

# Private ====================
