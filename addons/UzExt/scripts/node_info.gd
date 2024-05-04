extends Node

## 目標
@export var target : Node = null

## 標籤
@export var tags : Array[String] = []

## 成員
@export var members : Dictionary = {}


func get_member (key: String) :
	if not self.members.has(key) : return null
	var member = self.members[key]
	if member is NodePath :
		member = self.get_node(member)
	return member
