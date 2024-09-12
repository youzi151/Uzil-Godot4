
# Variable ===================

var Hurt

var _nxt_id : int = 0

var _id_to_bill : Dictionary = {}

var _bills : Array = []

# GDScript ===================

func _init (index_hurt) :
	self.Hurt = index_hurt

# Extends ====================

# Interface ==================

# Public =====================

func has_bill (id: int) :
	return self._id_to_bill.has(id)

func get_bill (id: int) :
	if not self._id_to_bill.has(id) : return null
	return self._id_to_bill[id]

func new_bill (data := {}) :
	var id : int = self._nxt_id
	self._nxt_id += 1
	
	var bill = Hurt.Bill.new(self)
	bill.id = id
	bill.set_data(data)
	
	self._id_to_bill[id] = bill
	self._bills.push_back(bill)
	return bill

func done_bill (id_or_bill) :
	var bill = id_or_bill
	if id_or_bill is String :
		if not self._id_to_bill.has(id_or_bill) : return
		bill = self._id_to_bill[id_or_bill]
	
	self._id_to_bill.erase(bill.id)
	
	bill.is_done = true

# Private ====================
