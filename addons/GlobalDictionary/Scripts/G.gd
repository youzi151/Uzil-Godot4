extends Node

# 將此Node節點設為AutoLoad, 並命名為"G".
# 就可以用G.v.key或G.v["key"]的方式存取一個全域Dictionary中的值.

# add this node in to singleton/autoload, and name "G".
# then there is a global dictionary can access value with G.v.key or G.v["key"].

var v := {}

func set_global (_name : String, val) :
	self.v[_name] = val
	if _name in self :
		self[_name] = val


# 其他需要事先定義的變數可以新增在下方
# other custom variable that don't need to in runtime can define below
#=======================================

var Uzil = null
