extends Node

# Variable ===================

var util

# GDScript ===================

func _ready () :
	self.util = UREQ.acc(&"Uzil:Util")
	self.test_merge_ex()

# Extends ====================

# Public =====================

func test_merge_ex () :
	var a : Dictionary = {
		"str": "str:%s",
		"dict": {
			"wtf": "haha",
			"num": 1,
			"arr": [1, 2, 7],
		},
		"regex": {
			"a123": 1,
			"a124": 2,
			"a225": 3,
			"need_rm_9999_e": 99,
			"need_rm_1111_e": 99,
		},
		"num": 5,
	}
	var aa : Dictionary = a.duplicate()
	var b : Dictionary = {
		"%str": ["{TEST}"],
		"+dict": {
			"-wtf": null,
			"+num": 1,
			"|arr": [8, 9],
			"+arr": [4, 5],
			"-arr": [7, 8],
			"new_field": "hi",
		},
		"+regex": {
			"+\\a1[\\d]*": 100,
			"-\\need_rm_.*_e": null,
		},
		"-num": 99,
	}
	var c : Dictionary = {
		"%str": {
			"TEST": "66666",
		}
	}
	self.util.dict.merge_ex(aa, b)
	self.util.dict.merge_ex(aa, c)
	G.print("raw:%s\n  merged:%s" % [a, aa])
	
	self.util.dict.merge_ex(aa, {
		"dict": {
			"shouldnt replace": 123,
		}
	})
	G.print(aa)
	
	self.util.dict.merge_ex(aa, {
		"=dict": {
			"should replace": 123,
		}
	})
	G.print(aa)
	
	
