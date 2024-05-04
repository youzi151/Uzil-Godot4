extends Node

# Variable ===================

## 偵錯文字
@export
var debug_log : Node = null

# GDScript ===================

func _ready () :
	G.on_print(func(msg):
		self.debug_log.add_text(msg + "\n")
	, "test_graph")

func _exit_tree () :
	G.off_print("test_graph")

# Extends ====================

# Interface ==================

# Public =====================

# Private ====================

func test_simple () :
	
	G.print("to find 4 -> 8")
	
	var Graph = UREQ.acc("Uzil", "Util").Graph
	
	var graph = Graph.new({
		"points" : {
			0 : {
				"nexts" : {
					1 : 1,
					5 : 1,
					9 : 1
				}
			},
			1 : {
				"nexts" : {
					2 : 1,
				}
			},
			2 : {
				"nexts" : {
					0 : 1,
					3 : 1,
				}
			},
			3 : {
				"nexts" : {
					4 : 1,
					7 : 1,
				}
			},
			4 : {},
			5 : {
				"nexts" : {
					2 : 1,
					6 : 1,
					9 : 1,
				}
			},
			6 : {
				"nexts" : {
					7 : 1,
				}
			},
			7 : {
				"nexts" : {
					5 : 1,
					8 : 1,
				}
			},
			8 : {},
			9 : {
				"nexts" : {
					10 : 1
				}
			},
			10 : {
				"nexts" : {
					8 : 1
				}
			}
		}
	})
	graph.refresh()
	
	var start_time = Time.get_ticks_usec()
	var through = [9]
	through.reverse()
	
	
	var result
	var opt = {
		#"is_fast_find" : false,
		"through" : through,
		"direction" : -1,
		#"deep_find_range" : [-1, -1],
	}
	
	var stack := [0, 1, 2, 3, 4]
	
	var found_reverse_paths := []
	
	var back_path := []
	var end_id := 8
	
	for idx in range(stack.size()-1, -1, -1) :
		
		var each : int = stack[idx]
		back_path.push_back(each)
		
		result = graph.find_path(end_id, each, opt)
		if result.result_paths.size() > 0 :
			found_reverse_paths = result.result_paths
			break
		
		if result.has("searched_paths") :
			opt["searched_paths"] = result.searched_paths
		
	#G.print("result path : ")
	#G.print(result.result_paths)
	#G.print("searched_paths : ")
	#G.print(result.searched_paths)
	
	G.print("found_reverse_paths")
	G.print(found_reverse_paths)
	
	if found_reverse_paths.size() > 0 :
		G.print("1. back path :")
		G.print(back_path)
		
		G.print("2. forward path :")
		found_reverse_paths.sort_custom(func(a, b):
			return a.size() < b.size()
		)
		var found_path = found_reverse_paths[0]
		found_path.reverse()
		G.print(found_path)
	else :
		G.print("There is no path to end")
	
	var end_time = Time.get_ticks_usec()
	
	G.print("cost time : %s" % ((end_time - start_time) / 1000000.0))

