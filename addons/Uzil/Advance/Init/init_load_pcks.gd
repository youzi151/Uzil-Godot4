
# Variable ===================

## 設定檔 路徑
var cfg_path_in_config_folder : String = "pcks.cfg"

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

func load () :
	var config = UREQ.acc(&"Uzil:user_save").config
	var arr = config.read(self.cfg_path_in_config_folder, "pcks")
	if arr != null :
		for each : String in arr :
			var is_success := ProjectSettings.load_resource_pack(each)
			if not is_success : 
				G.print("failed to load pck : %s" % each)

# Private ====================

