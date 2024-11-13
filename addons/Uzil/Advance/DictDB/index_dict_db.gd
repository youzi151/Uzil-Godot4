# desc ==========

## 索引 DictDB 字典資料庫
##
## 
##

# const ========

## 路徑
var PATH : String

## 腳本路徑
var SCRIPT_PATH : String

# sub_index =====

var Info

var Inst

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("DictDB")
	self.SCRIPT_PATH = self.PATH.path_join("_scripts")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"DictDB",
		func():
			
			self.Info = Uzil.load_script(self.SCRIPT_PATH.path_join("dict_db_info.gd"))
			self.Inst = Uzil.load_script(self.SCRIPT_PATH.path_join("dict_db_inst.gd"))
			
			return self,
		{
			"alias":[]
		}
	)
	
	UREQ.bind(&"Uzil", &"dict_dbs",
		func():
			var mgr = UREQ.acc(&"Uzil:Util").InstMgr.new(func(key):
				return self.Inst.new(self)
			)
			return mgr,
		{
			"alias":[],
			"requires":[
				&"DictDB"
			]
		}
	)
	
	return self
