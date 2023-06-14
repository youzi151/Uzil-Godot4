extends Uzil_Test_Base


# Variable ===================


# Extends ====================

func test_ready():
	self.test1()
#	self.test2()
	

func test_process(_delta):
	pass


# Public =====================

func test1 () :
	var tag_search = UREQ.access_g("Uzil", "tag_search")
	
	var inst = tag_search.inst("test")
	
#	var search_data = inst.parse_search_str(' -gender:male role : tank ,"super tank", dps (test, test2) ')
#	for each in search_data.tags :
#		print(each)
	
	inst.set_data("Aman", ["role:dps","gender:male"])
	inst.set_data("Bwoman", ["role:tank","gender:female"])
	inst.set_data("Cman", ["role:sup","gender:male"])
	inst.set_data("Dman", ["role:sup,tank","gender:male"])
	
	print(inst.search("-role:dps gender:male").keys())
	print(inst.search("role:sup - role : tank").keys())


