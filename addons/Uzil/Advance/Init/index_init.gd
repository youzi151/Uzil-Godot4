# desc ==========

## 索引 Init 初始化
##
## 常用初始化類
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 讀取PCK
var LoadPCKs
## 讀取選項設定
var LoadOpts

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Init")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Advance.Init",
		func():
			self.LoadPCKs = Uzil.load_script(self.PATH.path_join("init_load_pcks.gd"))
			self.LoadOpts = Uzil.load_script(self.PATH.path_join("init_load_opts.gd"))
			return self,
		{
			"alias" : ["Init"]
		}
	)

## 完整初始化
func init_full () :
	UREQ.acc(&"Uzil:Advance.Init")
	
	var load_pcks = self.LoadPCKs.new()
	load_pcks.load()
	
	var load_opts = self.LoadOpts.new()
	load_opts.load()
	
	
