extends Object

enum HandleMode {
	PERCENT,
	POSITION,
}

class Point :
	var x : float = 0.0
	var y : float = 0.0
	var lx : float = 0.0
	var ly : float = 0.0
	var rx : float = 0.0
	var ry : float = 0.0

# Variable ===================

var frames : Array[Point] = []

var handle_mode : HandleMode = HandleMode.PERCENT

var _is_sorted : bool = true

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 是否有效
func is_valid () :
	if self.frames.size() == 0 : return false
	
	var last_time : float = self.frames[0].x - 1
	for each in self.frames :
		if each.x < last_time : return false
		last_time = each.x
	
	return true

## 新增 影格
func add_frame (time: float, val: float, lx: float = 0.0, ly: float = 0.0, rx: float = 0.0, ry: float = 0.0) :
	var point : Point = Point.new()
	point.x = time
	point.y = val
	point.lx = lx
	point.ly = ly
	point.rx = rx
	point.ry = ry
	self.frames.push_back(point)
	
	self._is_sorted = false

func sort_frame () :
	self.frames.sort_custom(func(a, b):
		return a.x < b.x
	)
	self._is_sorted = true

## 取得 時機點上的值
func get_val (time: float, math: Object = null) :
	if not self._is_sorted :
		self.sort_frame()
	
	var frames_size : int = self.frames.size()
	if frames_size == 0 : return null
	
	var frame_begin : Point = self.frames[0]
	if time <= frame_begin.x : return frame_begin.y
	
	var frame_end : Point = self.frames[frames_size-1]
	if time >= frame_end.x : return frame_end.y
	
	var last_idx : int = -1
	for each_frame in self.frames :
		if time < each_frame.x :
			frame_begin = self.frames[last_idx]
			frame_end = each_frame
			break
		else :
			last_idx += 1
	var rx : float = frame_begin.rx
	var ry : float = frame_begin.ry
	var lx : float = frame_end.lx
	var ly : float = frame_end.ly
	
	match self.handle_mode :
		HandleMode.PERCENT :
			var length : float = frame_end.x - frame_begin.x
			var height : float = frame_end.y - frame_begin.y
			rx = frame_begin.x + (length * rx)
			ry = frame_begin.y + (height * ry)
			lx = frame_end.x + (length * lx)
			ly = frame_end.y + (height * ly)
	
	var p0 = Vector2(frame_begin.x, frame_begin.y)
	var p1 = Vector2(rx, ry)
	var p2 = Vector2(lx, ly)
	var p3 = Vector2(frame_end.x, frame_end.y)
	
	
	if math == null :
		math = UREQ.acc("Uzil", "Util").math
	#G.print("%s %s %s %s" % [p0, p1, p2, p3])
	var weight : float = math.bezier_find_weight(p0.x, p1.x, p2.x, p3.x, time, 0.0001, 200)
	var res : float = p0.bezier_interpolate(p1, p2, p3, weight).y
	#G.print("time[%s] = weight[%s] = val[%s]" % [time, weight, res])
	return res

# Private ====================

