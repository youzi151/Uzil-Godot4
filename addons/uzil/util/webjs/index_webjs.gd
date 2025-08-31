# desc ==========

## 索引 WebJS JavaScript
##
## 與Web JavaScript層溝通
##

# const =========

## 路徑
var PATH : String

# sub_index =====

# inst ==========

## 主體
var JS

## 檔案
var FS

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("webjs")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Util.WebJS",
		func():
			self.JS = Uzil.load_script(self.PATH.path_join("webjs.gd"))
			self.FS = Uzil.load_script(self.PATH.path_join("webjs_fs.gd"))
			return self, 
		{
			"alias" : ["WebJS"],
		}
	)
	
	# 綁定 池隨機 管理
	UREQ.bind(&"Uzil", &"webjs",
		func():
			if not OS.has_feature("web") : 
				G.print("[WebJS] not support non-web")
			var js = self.JS.new()
			await js.init()
			return js,
		{
			"is_async": true,
			"alias" : [],
			"requires" : ["Util", "Util.WebJS"],
		}
	)
	
	return self
