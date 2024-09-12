
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
