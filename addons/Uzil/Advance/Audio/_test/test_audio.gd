extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_audio")

func _exit_tree () :
	G.off_print("test_audio")

# Extends ====================

# Public =====================

func test_simple () :
	
	var Audio = UREQ.acc("Uzil", "Audio")
	var audio_mgr = UREQ.acc("Uzil", "audio_mgr")
	
	var invoker = UREQ.acc("Uzil", "invoker")
	
	# 清除前次
	audio_mgr.set_preset("test_key", null)
	audio_mgr.del_layer("layer1")
	audio_mgr.del_layer("layer2")
	audio_mgr.stop("obj1", true)
	audio_mgr.release("obj1")
	invoker.cancel_tag("test_audio_simple")
	
	# 設置 key與路徑
	audio_mgr.set_preset("test_key", Audio.PATH.path_join("_test/test.ogg"))
	
	# 設置 層級
	# 層級1 音量100% 優先度5
	var layer_test1 = audio_mgr.set_layer("layer1").set_volume(1).set_priority(5)
	# 層級2 音量  0% 優先度1
	var _layer_test2 = audio_mgr.set_layer("layer2").set_volume(0).set_priority(1)
	
	# 請求 並 設置 音效物件
	var audio_test1 = await audio_mgr.request("obj1", "test_key", {"bus":"BGM"})
	audio_test1.add_layers(["layer1", "layer2"])
	audio_test1.is_loop = true
	# 播放
	audio_test1.play()
	# 設置 bus音量
	#audio_mgr.set_bus_volume("Test", 0)
	# 註冊 當 循環結束 印出偵錯
	audio_test1.on_loop.on(func(_ctrlr):
		G.print("audio_test1 is looped")
	)
	
	# 數秒後
	invoker.once(func():
		# 層級1 降低優先度至-1
		layer_test1.set_priority(-1)
		G.print("layer_test1 set_priority : -1")
		
		# 數秒後
		invoker.once(func():
			# 停止音效
			audio_test1.stop()
			G.print("audio_test1 stop")
			
			# 播放 匿名音效 並 印出ID
			var new_audio = audio_mgr.emit("test_key")
			G.print("new audio emit : %s" % new_audio._id)
			
		, 2000).tag("test_audio_simple")
	, 2000).tag("test_audio_simple")

func test_process (_delta) :
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

