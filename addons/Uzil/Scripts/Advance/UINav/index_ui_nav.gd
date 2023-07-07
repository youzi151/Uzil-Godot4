# desc ==========

## 索引 States 狀態機
##
## 簡單實現狀態機, 方便使用.
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 實體
var Mgr
## 實體
var Inst
## 鏈節點
var Chain

# inst ==========

# other =========

## 腳本
var name_to_handler_script := {}

var _name_to_handler_inst := {}

## 自帶 處理器 腳本 (名稱:腳本路徑)
var default_handler_scripts := {
	"vec2" : "handlers/ui_nav_handler_vec2.gd"
}

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("UINav")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Advance.UINav",
		func () :
			self.Mgr = Uzil.load_script(self.PATH.path_join("ui_nav_mgr.gd"))
			self.Inst = Uzil.load_script(self.PATH.path_join("ui_nav_inst.gd"))
			self.Chain = Uzil.load_script(self.PATH.path_join("ui_nav_chain.gd"))
			
			for key in self.default_handler_scripts :
				var script = Uzil.load_script(self.PATH.path_join(self.default_handler_scripts[key]))
				self.import_handler_script(key, script)
			
			return self,
		{
			"alias" : ["UINav"],
		}
	)
	
	# 綁定 實體管理
	UREQ.bind("Uzil", "ui_nav",
		func () :
			var target = self.Mgr.new(null)
			target.name = "ui_nav"
			Uzil.add_child(target)
			return target,
		{
			"alias" : ["ui_nav_mgr"],
			"requires" : ["Advance.UINav"],
		}
	)
	return self


## 匯入 處理器 腳本
func import_handler_script (import_name, path_or_script) :
	self.name_to_handler_script[import_name] = path_or_script

## 取得 處理器 實體
func get_handler (name) :
	var inst = null
	
	if self._name_to_handler_inst.has(name) :
		inst = self._name_to_handler_inst[name]
	else :
		var Util = UREQ.acc("Uzil", "Util")
		var script = Util.gdscript.get_script_from_dict(self.name_to_handler_script, name)
		inst = script.new()
		self._name_to_handler_inst[name] = inst
	
	return inst
