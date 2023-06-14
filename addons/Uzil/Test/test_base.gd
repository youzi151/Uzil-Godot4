extends Node

class_name Uzil_Test_Base

@export
var active := false

var debug_msg = null

var _is_ready_done := false

# Called when the node enters the scene tree for the first time.
func _ready () :
	if not self.active : 
		self.test_unactive()
		return
	
	if self._is_ready_done : return
	self._is_ready_done = true
	
	self.debug_msg = self.get_tree().get_root().get_node("Uzil_Test/scene/debug_msg")
	
	self.test_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process (_dt) :
	if not self.active : return
	self.test_process(_dt)

func test_unactive () :
	pass

func test_ready () : 
	pass
	
func test_process (_dt) :
	pass

func test_print (msg) :
	print(msg)
	if self.debug_msg :
		self.debug_msg.text += str(msg)+"\n"
