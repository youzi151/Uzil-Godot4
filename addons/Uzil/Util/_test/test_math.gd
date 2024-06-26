extends Node

# Variable ===================

var util

# GDScript ===================

func _ready () :
	self.util = UREQ.acc(&"Uzil:Util")
	#G.print(cubic_interpolate(0.0, 1.0, 0.0, 1.0, 0.1))
	#G.print(self.util.math.bezier_find_weight(0.0, 0.0, 1.0, 1.0, 0.25, 0.001))
	self.test_cubic_bezier_1()

# Extends ====================

# Public =====================

func test_cubic_bezier_1 () :
	
	var p0 = Vector2(0, 0)
	var p1 = Vector2(1, 0)
	var p2 = Vector2(0, 1)
	var p3 = Vector2(1, 1)
	var times = [0, 0.0001, 0.25, 0.5, 0.75, 1]
	var deviation = 0.001
	
	G.print("%s %s %s %s" % [p0, p1, p2, p3])
	for each in times :
		var weight = self.util.math.bezier_find_weight(p0.x, p1.x, p2.x, p3.x, each, deviation)
		G.print("y in %s : %s" % [each, p0.bezier_interpolate(p1, p2, p3, weight)])

func test_cubic_bezier_2 () :
	
	var p0 = Vector2(0, 0)
	var p1 = Vector2(1, 0)
	var p2 = Vector2(0, 1)
	var p3 = Vector2(1, 1)
	var time = 0.75
	var deviation = 0.001
	
	G.print("%s %s %s %s" % [p0, p1, p2, p3])
	var weight = self.util.math.bezier_find_weight(p0.x, p1.x, p2.x, p3.x, time, deviation)
	G.print(p0.bezier_interpolate(p1, p2, p3, weight))
