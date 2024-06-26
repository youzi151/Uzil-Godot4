# desc ==========

## 索引 UserSave 用戶存檔
##
## 以 統一介面 存取 用戶 不同層級 的 存檔資料.
## 

class UserSaveKit :
	var config
	var user
	var profile

# const =========

## 路徑
var PATH : String

## 模板路徑
var TEMPLATE_PATHS : Array = []

## 格式版本
const FORMAT_VERSION := "1.0.0t"

## 存檔路徑
const SAVE_FOLDER_ROOT_PC := "./userdata"
const SAVE_FOLDER_ROOT_MOBILE := "user://userdata"
const SAVE_FOLDER_ROOT_WEB := "user://userdata"

# sub_index =====

## 實例
var Inst

## 策略 檔案
var Strat_File
## 策略 設定
var Strat_Cfg

## 配置 設定
var Setting_Config
## 配置 個人檔案
var Setting_Profile
## 配置 用戶
var Setting_User

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("UserSave")
	
	# 內建路徑 (需要在匯出設定中添加 "*.txt, *.cfg" 資源)
	self.TEMPLATE_PATHS.push_back(self.PATH.path_join("_template"))
	self.TEMPLATE_PATHS.push_back("res://userdata")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Basic.UserSave", 
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("user_save_inst.gd"))
			self.Strat_File = Uzil.load_script(self.PATH.path_join("user_save_strat_file.gd"))
			self.Strat_Cfg = Uzil.load_script(self.PATH.path_join("user_save_strat_cfg.gd"))
			self.Setting_Config = Uzil.load_script(self.PATH.path_join("user_save_setting_config.gd"))
			self.Setting_Profile = Uzil.load_script(self.PATH.path_join("user_save_setting_profile.gd"))
			self.Setting_User = Uzil.load_script(self.PATH.path_join("user_save_setting_user.gd"))
			return self, 
		{
			"alias" : ["UserSave"]
		}
	)
	
	# 綁定 工具組
	UREQ.bind(&"Uzil", &"user_save",
		func():
			return self.create_kit(),
		{
			"alias" : ["usersave"],
			"requires" : ["Basic.UserSave"],
		}
	)
	
	return self


## 建立 快速工具組
func create_kit () -> UserSaveKit :
	
	var save_folder_root = self.get_save_folder_root()
	
	# 設定檔
	#var config = self.Config.new(save_folder_root)
	#config.template_paths.push_back(self.TEMPLATE_PATH)
	#config.template_paths.push_back("res://userdata")
	# 靜態設定檔(運行時不將模板檔案複製到儲存位置)
	#if OS.has_feature("editor") or OS.has_feature("uzil.static_config") :
		#config.is_copy_from_template_to_userdata = false
	
	# 設定
	var setting_config = self.Setting_Config.new()
	var setting_user = self.Setting_User.new()
	var setting_profile = self.Setting_Profile.new(setting_user)
	
	# 設置 預設
	setting_config.set_folder(save_folder_root).add_template_folders(self.TEMPLATE_PATHS)
	setting_config.flags["allow_cache"] = false
	setting_user.set_user("unknown").set_folder(save_folder_root)
	setting_profile.set_profile("default").set_folder(save_folder_root)
	
	# 策略
	var strat_file = self.Strat_File.new(self.FORMAT_VERSION)
	var strat_cfg = self.Strat_Cfg.new()
	
	# 存檔器實體
	var config = self.Inst.new(strat_cfg, setting_config)
	var user = self.Inst.new(strat_file, setting_user)
	var profile = self.Inst.new(strat_file, setting_profile)
	
	var kit := UserSaveKit.new()
	kit.config = config
	kit.user = user
	kit.profile = profile
	return kit

## 取得 存檔 根目錄
func get_save_folder_root () -> String :
	if OS.has_feature("web") :
		return self.SAVE_FOLDER_ROOT_WEB
	elif OS.has_feature("mobile") :
		return self.SAVE_FOLDER_ROOT_MOBILE
	elif OS.has_feature("pc") :
		return self.SAVE_FOLDER_ROOT_PC
	
	# TODO : console
	
	return self.SAVE_FOLDER_ROOT_PC
