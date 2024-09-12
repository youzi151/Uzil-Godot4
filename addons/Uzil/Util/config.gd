
## Config相關
##
## 處理 Config 的 相關事務
## 

func load_cfg_dict (path: String, opts := {}) :
	var file : ConfigFile = ConfigFile.new()
	if file.load(path) != OK : return null
	
	var is_ignore_section : bool = true
	if opts.has("is_ignore_section") :
		is_ignore_section = opts["is_ignore_section"]
	
	var key_to_val : Dictionary = {}
	var cur_dict : Dictionary = key_to_val
	
	var sections : Array = file.get_sections()
	for sec in sections :
		if not is_ignore_section :
			cur_dict = {}
			key_to_val[sec] = cur_dict
			
		for key in file.get_section_keys(sec) :
			var each = file.get_value(sec, key)
			cur_dict[key] = each
	
	return key_to_val
