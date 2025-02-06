
var gdbridge : JavaScriptObject

var fs = null

var _js_callbacks : Dictionary = {}

## 初始化
func init () :
	if not OS.has_feature("web") : return
	
	var WebJS = UREQ.acc(&"Uzil:Util.WebJS")
	
	self.fs = WebJS.FS.new(self)
	
	# 設置 預製物件
	var res = UREQ.acc(&"Uzil:res")
	var res_info = await res.hold(WebJS.PATH.path_join("gdbridge.js.txt"))
	if res_info != null : 
		JavaScriptBridge.eval(res_info.res.text, true)
	self.gdbridge = JavaScriptBridge.get_interface("gdbridge")

## 偵錯印出
func log (msg) :
	if self.gdbridge != null :
		self.gdbridge.log(str(msg))

## 設置 回呼
func set_callabck (id: String, cb: Callable) :
	self.gdbridge.setCB(id, cb)

## 呼叫
func invoke (msg: String, args := []) :
	var ref : Dictionary = {
		"ret_cb": null,
		"res": null,
	}
	
	var jargs = JavaScriptBridge.create_object("Array", args.size())
	for idx in args.size() :
		jargs[idx] = args[idx]
	
	var signal_ctrlr = UREQ.acc(&"Uzil:Util").async.signal_waiter()
	var ret_cb : JavaScriptObject = JavaScriptBridge.create_callback(func(cb_args):
		self._js_callbacks.erase(ref["ret_cb"])
		ref["res"] = cb_args[0]
		signal_ctrlr.emit()
	)
	self._js_callbacks[ret_cb] = true
	ref["ret_cb"] = ret_cb
	
	self.gdbridge.invoke(msg, jargs, ret_cb)
	
	await signal_ctrlr.until_emit()
	
	var res = ref["res"]
	ref.clear()
	
	return res

## 註冊 偵聽
func on (msg: String, id: String, cb: Callable) :
	var ref : Dictionary = {
		"ret_cb": null,
		"res": null,
	}
	
	var signal_ctrlr = UREQ.acc(&"Uzil:Util").async.signal_waiter()
	
	var on_cb : JavaScriptObject = JavaScriptBridge.create_callback(func(ret_arr):
		cb.call(ret_arr)
	)
	self._js_callbacks[id] = on_cb
	
	var ret_cb : JavaScriptObject = JavaScriptBridge.create_callback(func(ret_arr):
		ref["res"] = ret_arr
		signal_ctrlr.emit()
	)
	self._js_callbacks[ret_cb] = true
	ref["ret_cb"] = ret_cb
	
	self.gdbridge.on(msg, id, on_cb, ret_cb)
	
	await signal_ctrlr.until_emit()
	
	return ref["res"]

## 取消 偵聽
func off (msg: String, id: String) :
	
	if self._js_callbacks.has(id) :
		self._js_callbacks.erase(id)
	
	var ref : Dictionary = {
		"ret_cb": null,
		"res": null,
	}
	
	var signal_ctrlr = UREQ.acc(&"Uzil:Util").async.signal_waiter()
	
	var ret_cb : JavaScriptObject = JavaScriptBridge.create_callback(func(ret):
		self._js_callbacks.erase(ref["ret_cb"])
		ref["res"] = ret[0]
		signal_ctrlr.emit()
	)
	self._js_callbacks[ret_cb] = true
	ref["ret_cb"] = ret_cb
	
	self.gdbridge.off(msg, id, ret_cb)
	
	await signal_ctrlr.until_emit()
	
	return ref["res"]
