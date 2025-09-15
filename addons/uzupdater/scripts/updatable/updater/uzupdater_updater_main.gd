
## Uzupdater.Updater.Main 主要 更新器
##
## 更新 遊戲內容的部分.
##

# Variable ===================

# GDScript ===================

# Extends ====================

# Public =====================

## 開始
func start_update (task, callback_fn: Callable) :
	print("==== updater_main update start")
#	print("uzupdater updater main in pck")
	
	var uzupdater = task.uzupdater
	
	# 更新器列表 (即時讀取並建立)
	var updater_list := [
		["pck", uzupdater.load_updater("uzupdater_updater_pck.gd").new()]
	]
	
	# 每個 更新器 準備更新
	for each in updater_list :
		each[1].prepare_update(task)
	
	# 每個 更新器 依序 開始更新
	await uzupdater.async.each_series(
		updater_list,
		func(idx, each, ctrlr):
			# 名稱
			var name : String = each[0]
			# 更新器
			var updater = each[1]
			
			# 開始更新
			updater.start_update(task, func(err):
				# 若有錯誤
				if err != null :
					err = "updater[%s] error : %s" % [name, err]
					callback_fn.call(err)
					return
				
				# 下個更新器
				ctrlr.next()
			),
	)
	
	print("==== updater_main update end")
	callback_fn.call(null)
	
# Private ====================
