# desc ==========

## 索引 Buffs 附加狀態
##
## 
##

# const ========

## 路徑
var PATH : String

# sub_index =====

## 實例
var Inst

## 附加狀態
var Buff

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("Buffs")
	
	# 綁定 索引
	UREQ.bind(&"Uzil", &"Game.Buffs",
		func():
			self.Inst = Uzil.load_script(self.PATH.path_join("buffs_inst.gd"))
			self.Buff = Uzil.load_script(self.PATH.path_join("buffs_buff.gd"))
			
			return self,
		{
			"requires":[&"Uzil:handlers"],
			"alias":[&"Buffs"]
		}
	)
	
	UREQ.bind(&"Uzil", &"buffs",
		func():
			var mgr = UREQ.acc(&"Uzil:Util").InstMgr.new(func(key):
				var buffs_inst = self.Inst.new(self)
				buffs_inst.id = key
				return buffs_inst
			)
			return mgr
			,
		{
			"requires":[&"Uzil:Game.Buffs"],
			"alias":[],
		}
	)
	
	return self
