
## TaskQueue.Task行動佇列 任務
## 
## 
## 

# Variable ===================

## 排序
var sort : float = 0.0

## 名稱
var name : String = ""

## 行動內容
var act_func : Callable

## 標記
var flags : Array = []

## 需要 標記
var need_flags : Array = []

## 等候 標記
var wait_flags : Array = []

## 批次 標記
var batch_flags : Array = []

## 預先 標記
var reserve_flags : Array = []

## 遺留 標記
var drop_flags : Array = []

## 拿取 標記
var take_flags : Array = []

# GDScript ===================

func _to_string () :
	return self.name

# Extends ====================

# Interface ==================

# Public =====================

## 設置 排序
func srt (_sort: float) :
	self.sort = _sort

## 設置 名稱
func nm (_name: String) :
	self.name = _name

## 設置 行為
func fn (_fn: Callable) :
	self.act_func = _fn
	return self

## 設置 標記
func flgs (_flags: Array) :
	self.flags.append_array(_flags)
	return self

## 設置 需要標記
func need (_flags: Array) :
	self.need_flags.append_array(_flags)
	return self

## 設置 等待/加入標記
func wait (_flags: Array) :
	self.wait_flags.append_array(_flags)
	return self

## 設置 批次標記
func batch (_flags: Array) :
	self.batch_flags.append_array(_flags)
	return self

## 設置 預定標記
func reserve (_flags: Array) :
	self.reserve_flags.append_array(_flags)
	return self

## 設置 遺留標記
func drop (_flags: Array) :
	self.drop_flags.append_array(_flags)
	return self

## 設置 取用標記
func take (_flags: Array) :
	self.take_flags.append_array(_flags)
	return self


# Private ====================
