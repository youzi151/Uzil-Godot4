extends Node

# Variable ===================

var TaskQueue

## 偵錯文字
@export
var debug_log : Node = null

# GDScript ===================

func _ready () :
	G.on_print(func(msg) : 
		self.debug_log.add_text(msg + "\n")
	, "test_task_queue")
	
	self.TaskQueue = UREQ.acc(&"Uzil:TaskQueue")

func _exit_tree () :
	G.off_print("test_task_queue")

# Extends ====================

# Interface ==================

# Public =====================

## 基本測試 - 簡單任務執行
func test_basic () :
	G.print("== TaskQueue Basic Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed")
	)
	
	# 建立任務 2
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed")
	)
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	
	# 執行
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task1", "task2"], "Basic test failed")
	queue_inst.clear()

## 測試 need_flags - 需要標記才能執行
func test_need_flags () :
	G.print("== TaskQueue Need Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	var block_node : Node = Node.new()
	self.add_child(block_node)
	
	# 建立任務 1 - 設置標記 "flag_a"
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - set flag_a")
		await block_node.tree_exited
	)
	task1.flgs(["flag_a"])
	
	# 建立任務 2 - 需要標記 "flag_a" 才能執行
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed - needs flag_a")
		self.remove_child(block_node)
	)
	task2.need(["flag_a"])
	
	# 建立任務 3 - 需要不存在的標記，不應執行
	var task3 = self.TaskQueue.Task.new()
	task3.fn(func():
		exec_log.append("task3")
		G.print("Task 3 executed - should not execute")
	)
	task3.need(["flag_b"])
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	queue_inst.add_task(task3)
	
	# 執行
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task1", "task2"], "Need flags test failed not %s" % [exec_log])
	queue_inst.clear()

## 測試 wait_flags - 等待標記（阻止執行）
func test_wait_flags () :
	G.print("== TaskQueue Wait Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	var block_node : Node = Node.new()
	self.add_child(block_node)
	
	# 建立任務 1 - 預先設置標記 "flag_a"（使用 reserve 確保標記在執行前就存在）
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - set flag_a")
		await block_node.tree_exited
	)
	task1.flgs(["flag_a"])
	
	# 建立任務 2 - 等待標記 "flag_a"（存在則阻止）
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed - should not execute until erase flag_a")
	)
	task2.wait(["flag_a"])
	
	# 建立任務 3 - 等待標記 "*flag_a"（存在則允許）
	var task3 = self.TaskQueue.Task.new()
	task3.fn(func():
		exec_log.append("task3")
		G.print("Task 3 executed - wait *flag_a (*:join)")
		self.remove_child(block_node)
	)
	task3.wait(["*flag_a"])
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	queue_inst.add_task(task3)
	
	# 執行
	queue_inst.process()
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task1", "task3", "task2"], "Wait flags test failed not %s" % [exec_log])
	queue_inst.clear()

## 測試 batch_flags - 批次任務
func test_batch_flags () :
	G.print("== TaskQueue Batch Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	var block_node : Node = Node.new()
	self.add_child(block_node)
	
	# 建立批次任務 1
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - batch_a, execute when flag_start and second_start")
	)
	task1.batch(["batch_a"])
	task1.need(["flag_start", "second_start"])
	
	# 建立批次任務 2
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed")
	)
	task2.need(["flag_start"])
	
	# 建立批次任務 3
	var task3 = self.TaskQueue.Task.new()
	task3.fn(func():
		exec_log.append("task3")
		G.print("Task 3 executed - execute when second_start")
	)
	task3.need(["second_start"])
	
	# 建立批次任務 4
	var task4 = self.TaskQueue.Task.new()
	task4.fn(func():
		exec_log.append("task4")
		G.print("Task 4 executed - batch_a, execute when flag_start")
	)
	task4.batch(["batch_a"])
	task4.need(["flag_start"])
	
	# 建立任務設置標記
	var task_start = self.TaskQueue.Task.new()
	task_start.fn(func():
		exec_log.append("start")
		G.print("set flag_start")
		await block_node.tree_exited
	)
	task_start.flgs(["flag_start"])
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	queue_inst.add_task(task3)
	queue_inst.add_task(task4)
	queue_inst.add_task(task_start)
	
	# 執行
	queue_inst.process()
	queue_inst.process()
	queue_inst.process()
	
	G.print("wait sec")
	await get_tree().create_timer(1.0).timeout
	queue_inst.add_flag("second_start")
	G.print("set second_start")
	queue_inst.process()
	
	self.remove_child(block_node)
	
	# 驗證 - 批次任務應該一起執行
	G.print("Execution log: %s" % [exec_log])
	var correct_order := ["start", "task2", "task1", "task3", "task4"]
	assert(exec_log == correct_order, "Execute not order by %s" % [correct_order])

## 測試 reserve_flags - 預先標記
func test_reserve_flags () :
	G.print("== TaskQueue Reserve Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1 - 預先設置標記 "reserved_flag"
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - shouldn't execute")
	)
	task1.need(["never_flag"])
	task1.reserve(["reserved_flag"])
	
	# 建立任務 2 - 需要預先標記
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2 only")
		G.print("Task 2 executed - needs reserved_flag")
	)
	task2.need(["reserved_flag"])
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	
	# 執行
	queue_inst.process()
	
	# 驗證 - task2 應該能執行，因為 task1 預先設置了標記
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task2 only"], "Reserve flags test failed")

## 測試 drop_flags - 遺留標記
func test_drop_flags () :
	G.print("== TaskQueue drop Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1 - 需要標記
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - needs flag_a")
	)
	task1.need(["flag_a"])
	
	# 建立任務 2 - 遺留
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed - drop flag_a")
	)
	task2.drop(["flag_a"])
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	
	queue_inst.process()
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task2", "task1"], "drop flags test failed")

## 測試 take_flags - 拿取標記
func test_take_flags () :
	G.print("== TaskQueue Take Flags Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1 - 等候標記結束
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - wait flag_wait if it exists")
	)
	task1.wait(["flag_wait"])
	
	# 建立任務 2 - 預定並拿取標記
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed - take flag_wait")
	)
	task2.reserve(["flag_wait"])
	task2.need(["flag_start"])   # 拿取標記，減少 count
	task2.take(["flag_wait"])
	
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	
	queue_inst.process()
	queue_inst.process()
	
	queue_inst.add_flag("flag_start")
	
	queue_inst.process()
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert(exec_log == ["task2", "task1"], "Take flags test failed, not %s" % [exec_log])

## 測試處理中任務變更
func test_processing_changes () :
	G.print("== TaskQueue Processing Changes Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1 - 在執行中會添加新任務
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed - will add task3")
		
		# 在執行中添加新任務
		var task3 = self.TaskQueue.Task.new()
		task3.fn(func():
			exec_log.append("task3")
			G.print("Task 3 executed - added during processing")
		)
		queue_inst.add_task(task3)
	)
	
	# 建立任務 2
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed")
	).srt
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	
	# 執行
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert("task1" in exec_log, "Task 1 should execute")
	assert("task2" in exec_log, "Task 2 should execute")
	assert("task3" in exec_log, "Task 3 should execute (added during processing)")

## 測試複雜場景
func test_complex () :
	G.print("== TaskQueue Complex Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立初始任務 - 設置多個標記並遺留
	var task_init = self.TaskQueue.Task.new()
	task_init.fn(func():
		exec_log.append("init")
		G.print("Init task - set flags")
	)
	task_init.reserve(["flag_a", "flag_b"])
	task_init.flgs(["flag_a", "flag_b"])
	task_init.drop(["flag_a", "flag_b"])  # 遺留標記，確保標記持續存在
	
	# 建立任務 1 - 需要 flag_a，設置 flag_c
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 - need flag_a, set flag_c")
	)
	task1.need(["flag_a"])
	task1.reserve(["flag_c"])
	task1.flgs(["flag_c"])
	task1.drop(["flag_c"])  # 遺留標記
	
	# 建立任務 2 - 需要 flag_b 和 flag_c，批次執行
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 - batch, need flag_b and flag_c")
	)
	task2.batch(["batch_1"])
	task2.need(["flag_b", "flag_c"])
	
	# 建立任務 3 - 同批次
	var task3 = self.TaskQueue.Task.new()
	task3.fn(func():
		exec_log.append("task3")
		G.print("Task 3 - batch, need flag_b and flag_c")
	)
	task3.batch(["batch_1"])
	task3.need(["flag_b", "flag_c"])
	
	# 建立任務 4 - 等待 flag_a（不應執行）
	var task4 = self.TaskQueue.Task.new()
	task4.fn(func():
		exec_log.append("task4")
		G.print("Task 4 - wait flag_a (should not execute)")
	)
	task4.wait(["flag_a"])
	
	# 建立任務 5 - 等待 *flag_a（應執行）
	var task5 = self.TaskQueue.Task.new()
	task5.fn(func():
		exec_log.append("task5")
		G.print("Task 5 - wait *flag_a (should execute)")
	)
	task5.wait(["*flag_a"])
	
	# 加入任務
	queue_inst.add_task(task_init)
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	queue_inst.add_task(task3)
	queue_inst.add_task(task4)
	queue_inst.add_task(task5)
	
	# 執行
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert("init" in exec_log, "Init task should execute")
	assert("task1" in exec_log, "Task 1 should execute")
	assert("task2" in exec_log and "task3" in exec_log, "Batch tasks should execute")
	assert("task4" not in exec_log, "Task 4 should not execute (wait flag)")
	assert("task5" in exec_log, "Task 5 should execute (wait *flag)")

## 測試任務刪除
func test_delete_task () :
	G.print("== TaskQueue Delete Task Test")
	
	var exec_log := []
	var queue_inst = self.TaskQueue.Inst.new()
	
	# 建立任務 1
	var task1 = self.TaskQueue.Task.new()
	task1.fn(func():
		exec_log.append("task1")
		G.print("Task 1 executed")
	)
	
	# 建立任務 2
	var task2 = self.TaskQueue.Task.new()
	task2.fn(func():
		exec_log.append("task2")
		G.print("Task 2 executed")
	)
	
	# 建立任務 3
	var task3 = self.TaskQueue.Task.new()
	task3.fn(func():
		exec_log.append("task3")
		G.print("Task 3 executed")
	)
	
	# 加入任務
	queue_inst.add_task(task1)
	queue_inst.add_task(task2)
	queue_inst.add_task(task3)
	
	# 刪除 task2
	queue_inst.del_task(task2)
	
	# 執行
	queue_inst.process()
	
	# 驗證
	G.print("Execution log: %s" % [exec_log])
	assert("task1" in exec_log, "Task 1 should execute")
	assert("task2" not in exec_log, "Task 2 should not execute (deleted)")
	assert("task3" in exec_log, "Task 3 should execute")
