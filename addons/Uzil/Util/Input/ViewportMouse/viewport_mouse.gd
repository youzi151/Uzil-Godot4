
## 視圖滑鼠 ViewportMouse
##
## 用來處理滑鼠與視圖有關連的的部分屬性(如:位置)
## 會由放在SceneTree中的viewport_mouse_listener_node,
## 來蒐集該viewport的滑鼠資料, 並寫入在可全局取得的對應實例中.
##

## 實例

# Variable ===================

## 路徑
var PATH : String = ""

## 偵聽者 節點
var ViewportMouseListener = null

## 實例
var ViewportMouseInst = null

## 實例管理
var _inst_mgr = null

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

func init (Util) :
	var Uzil = UREQ.acc("Uzil", "Uzil")
	
	self.PATH = Util.PATH.path_join("Input/ViewportMouse")
	
	self.ViewportMouseInst = Uzil.load_script(self.PATH.path_join("viewport_mouse_inst.gd"))
	self.ViewportMouseListener = Uzil.load_script(self.PATH.path_join("viewport_mouse_listener_node.gd"))
	
	## 建立 實例管理
	self._inst_mgr = Util.InstMgr.new(func():
		return self.ViewportMouseInst.new()
	)
	return self

## 取得 對應視圖 的 實例
func in_viewport (viewport: Viewport) :
	return self._inst_mgr.inst(str(viewport.get_instance_id()))

# Private ====================

