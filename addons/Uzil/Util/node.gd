
## Node相關
##
## 處理 Node 的 相關事務
## 

func get_children_recursive (node: Node, is_internal: bool = false) :
	var to_check : Array = [node]
	var childs : Array = []
	while to_check.size() > 0 :
		var each_node : Node = to_check.pop_front()
		var each_childs : Array = each_node.get_children(is_internal)
		if each_childs.size() == 0 : continue
		childs.append_array(each_childs)
		to_check.append_array(each_childs)
	return childs

## WIP 重新設置上層節點
## 因為 reparent 可能在某些情況下導致node與其下層node 的 connection 斷開,
## 可能要考慮用公用工具來在斷開前紀錄, 並在重新設置上層節點後重新連接.
func reparent (node: Node, new_parent: Node, is_keep_global_pos := true) :
	var parent : Node = node.get_parent()
	if parent == new_parent : return
	
	if parent == null :
		
		new_parent.add_child(node)
		
	else :
		
		# 紀錄 原本的連接
		var signal_to_connections : Dictionary = {}
		var signals : Array = node.get_signal_list()
		for each in signals :
			signal_to_connections[each.name] = node.get_signal_connection_list(each.name)
		
		# 更換 上層節點
		node.set_meta("_is_reparenting", true)
		node.reparent(new_parent, is_keep_global_pos)
		node.remove_meta("_is_reparenting")
		
		# 恢復 原本的連接
		for sig in signal_to_connections :
			var connections : Array = signal_to_connections[sig]
			for each in connections :
				if not node.is_connected(sig, each.callable) :
					node.connect(sig, each.callable, each.flags)
				

func is_reparenting (node: Node) :
	return node.has_meta("_is_reparenting")
	
