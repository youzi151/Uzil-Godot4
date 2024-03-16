# desc ==========

## 索引 EvtBubb 事件冒泡
##
## 
## 

# const =========

## 路徑
var PATH : String

# sub_index =====

## 事件
var Evt

## 處理者
var Handler

## 處理者 節點
var HandlerNode

# inst ==========

# other =========

# func ==========

## 建立索引
func index (Uzil, _parent_index) :
	
	self.PATH = _parent_index.PATH.path_join("EvtBubb")
	
	# 綁定 索引
	UREQ.bind("Uzil", "Advance.EvtBubb",
		func () :
			self.Evt = Uzil.load_script(self.PATH.path_join("evt_bubb_evt.gd"))
			self.Handler = Uzil.load_script(self.PATH.path_join("evt_bubb_handler.gd"))
			self.HandlerNode = Uzil.load_node_script(self.PATH.path_join("evt_bubb_handler_node.gd"))
			
			return self,
		{
			"alias" : ["EvtBubb"]
		}
	)
	
