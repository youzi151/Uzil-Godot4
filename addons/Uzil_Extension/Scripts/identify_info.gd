extends Node

@export var tags : Array[String] = []

## 目標 節點路徑
@export var target_nodepath : NodePath = ""

## 目標
var target = null

func _ready () :
	self.target = self.get_node(self.target_nodepath)
