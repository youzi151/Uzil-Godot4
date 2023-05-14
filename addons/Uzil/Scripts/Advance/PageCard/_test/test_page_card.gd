extends Uzil_Test_Base

# Variable ===================

@export var pagecard_inst_nodepath : NodePath

var pagecard_inst


# Extends ====================

func test_ready():
	self.pagecard_inst = self.get_node(self.pagecard_inst_nodepath)
	
	var invoker = G.v.Uzil.invoker.inst()
	
	self.pagecard_inst.on_ready.on(func (_ctrlr) :
		var root_page = self.pagecard_inst.root_page
		
		# 設置 各頁面
		root_page.add_page("page_3d_obj", "3d")
		root_page.add_page("page_window", "2d")
		root_page.add_page("page_none", "none")
		root_page.add_page("page_all", "all")
		
		# 初次刷新
		self.pagecard_inst.refresh()
		
		G.v.Uzil.Util.async.waterfall([
			# 切換顯示 3D頁面堆
			func (ctrlr) :
				print("waterfall page 3d")
				root_page.switch_deck("3d")
				self.pagecard_inst.refresh()
				invoker.once(ctrlr.next, 1000),
			
			# 切換顯示 2D頁面堆
			func (ctrlr) :
				print("waterfall page 2d")
				root_page.switch_deck("2d")
				self.pagecard_inst.refresh()
				invoker.once(ctrlr.next, 1000),
			
			# 顯示 新頁面 在 2D頁面堆
			func (ctrlr) :
				print("waterfall page 2d + popup")
				
				# 添加 頁面 至 2D頁面堆
				root_page.add_page("page_popup", "2d")
				
				# 刷新 並 設置轉場
				self.pagecard_inst.refresh_with_transition(func(to_active_cards, to_deactive_cards, on_done):
					
					var to_trans_cards := []
					
					# 初始化 每張卡片
					for each_card in to_active_cards :
						# 若 已顯示 或 無"2d"標籤 則 忽略
						if each_card.is_active : continue
						if not each_card.tags.has("2d") : continue
						# 每個卡片中的對象
						for each_target in each_card.targets :
							# 透明度 0
							(each_target as CanvasItem).modulate.a = 0
							# 先啟用
							each_card.active()
							# 加入待轉場
							to_trans_cards.push_back(each_card)
					
					# 開始 每幀
					var ref := {}
					ref.task = invoker.update(func(_dt):
						# 是否完成轉場
						var is_done := true
						# 所有 要啟用的卡片
						for each_card in to_trans_cards :
							if not each_card.tags.has("2d") : continue
							# 每個卡片中的對象
							for each_target in each_card.targets :
								var each_cvs_item := (each_target as CanvasItem)
								
								# 漸變透明度
								each_cvs_item.modulate.a += 0.25 * _dt * 0.001
								
								# 若 尚未完全顯示 則 尚未完成
								if each_cvs_item.modulate.a < 1 :
									is_done = false
						# 若 已完成轉場
						if is_done :
							# 取消 每幀
							invoker.cancel_task(ref.task)
							# 呼叫 轉場完成
							on_done.call()
							# 數秒後 下一階段
							invoker.once(ctrlr.next, 1000)
					)
				),
			func (ctrlr) :
				print("waterfall page all")
				root_page.switch_deck("all")
				self.pagecard_inst.refresh()
				invoker.once(ctrlr.next, 1000),
			func (ctrlr) :
				print("waterfall page none")
				root_page.switch_deck("none")
				self.pagecard_inst.refresh()
				invoker.once(ctrlr.next, 1000),
			func (ctrlr) :
				print("waterfall page backto 2d")
				root_page.switch_deck("2d")
				self.pagecard_inst.refresh()
				invoker.once(ctrlr.next, 1000),
		])
		
	)

func test_process(_delta):
#	print(DisplayServer.window_get_size()) 
	pass

# Public =====================

