extends Uzil_Test_Base

# Variable ===================

# Extends ====================

func test_ready():
	
	var UserSave = UREQ.acc("Uzil", "Basic.UserSave")
	var user_save = UREQ.acc("Uzil", "user_save")
	
	test_print("os user path : %s" % OS.get_user_data_dir())
	test_print("uzil usersave path : %s" % UserSave.get_save_folder_root())
	
	test_print("== save full string")
	user_save.user.write("user_fullstr.sav", "fff")
	
	test_print("== save full dict")
	user_save.user.write("user_fulldict.sav", {
		"test":123,
		"test2":{
			"test":456
		}
	})
	
	test_print("== save dict val")
	user_save.user.write_val("user_fulldict.sav", "test2.test", 789)
	
	test_print("== read full string")
	test_print(user_save.user.read("user_fullstr.sav"))
	
	test_print("== read full dict")
	test_print(user_save.user.read("user_fulldict.sav"))
	
	test_print("== read dict val")
	test_print(user_save.user.read_val("user_fulldict.sav", "test2.test"))
	
	
	user_save.user.setting.set_user("steam_9527")
	
	test_print("== write/read user")
	user_save.user.write("user_steam_fullstr.sav", "strrrrr")
	test_print(user_save.user.read("user_steam_fullstr.sav"))
	
	test_print("== write/read profile")
	user_save.profile.setting.set_profile("John")
	user_save.profile.write("profile_fullstr.sav", "pppppppp")
	test_print(user_save.profile.read("profile_fullstr.sav"))
	
	

func test_process(_delta):
	pass

# Public =====================
