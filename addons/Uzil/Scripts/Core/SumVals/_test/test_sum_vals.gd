extends Uzil_Test_Base

# Variable ===================

var SumVals

# Extends ====================

func test_ready () :
	self.SumVals = UREQ.acc("Uzil", "Core.SumVals")
	
	self.test()

func test_process (_delta) :
	pass


# Public =====================

func test () :
	
	print("Uzil.Core.SumVals test")
	
	var sum_vals = self.SumVals.Inst.new()
	
	sum_vals.on_update("mail.guild", func(ctrlr):
		print("on update mail.guild to : %s " % ctrlr.data)
	)
	
	sum_vals.set_summary_val_fn(func (val, sub_vals) :
		var total = 0
		if val != null :
			total += val
		for each in sub_vals :
			total += each
		return total
	)
	
	sum_vals.set_result_overwrite_fn(func(val):
		return "%s + overwrite" % val
	)
	
	sum_vals.set_default(0)
	
	
	print("set mails")
	sum_vals.set_val("mail.friend.gift", 100, false)
	sum_vals.set_val("mail.guild.war", 1, false)
	sum_vals.set_val("mail.guild.salary", 0, false)
	sum_vals.update()
#
	print("set guild salary")
	sum_vals.set_val("mail.guild.salary", 7)
	sum_vals.set_val("mail.guild.salary.bonus", 10)
#
	print("del guild war")
	sum_vals.del_route("mail.guild.war")
	sum_vals.del_route("mail.guild.war.notexistkey")

	print("final mail box hint : %s " % sum_vals.get_sum_val("mail"))
	
	
	
