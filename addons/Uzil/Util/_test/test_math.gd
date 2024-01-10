
# Variable ===================

var util

# GDScript ===================

func _ready () :
	self.util = UREQ.acc("Uzil", "Util")

# Extends ====================

# Public =====================

func test_cubic_bezier_1 () :
	
	var p0 = Vector2(0, 0)
	var p1 = Vector2(1, 0)
	var p2 = Vector2(0, 1)
	var p3 = Vector2(1, 1)
	var times = [0, 0.25, 0.5, 0.75, 1]
	var deviation = 0.001
	
	G.print("%s %s %s %s" % [p0, p1, p2, p3])
	for each in times :
		var weight = self.util.math.cubic_bezier_find_weight(p0.x, p3.x, p1.x, p2.x, each, deviation)
		G.print(p0.bezier_interpolate(p1, p2, p3, weight))

func test_cubic_bezier_2 () :
	
	var p0 = Vector2(0, 0)
	var p1 = Vector2(1, 0)
	var p2 = Vector2(0, 1)
	var p3 = Vector2(1, 1)
	var time = 0.75
	var deviation = 0.001
	
	G.print("%s %s %s %s" % [p0, p1, p2, p3])
	var weight = self.util.math.cubic_bezier_find_weight(p0.x, p3.x, p1.x, p2.x, time, deviation)
	G.print(p0.bezier_interpolate(p1, p2, p3, weight))
