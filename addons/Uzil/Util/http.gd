
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 上傳檔案
func upload_file_buffer (url: String, file_name: String, content_type: String, content: PackedByteArray) :
	
	var http_node : Node = UREQ.acc(&"Uzil:Uzil").request_node("Http")
	# 等候器
	var signal_waiter : RefCounted = UREQ.acc(&"Uzil:Util").async.SignalWaiter.new()
	# 結果
	var response_ref := [null]
	
	# 建立請求
	var request := HTTPRequest.new()
	request.request_completed.connect(func(_result, _response_code, _headers, _body):
		# 若 請求成功
		if _result == HTTPRequest.RESULT_SUCCESS :
			# 取出結果
			response_ref[0] = _body.get_string_from_utf8()
			# 通知 等候器
			signal_waiter.emit()
		#else :
			#G.print("not connected to server")
		
		http_node.remove_child(request)
		request.queue_free()
	)
	http_node.add_child(request)
	
	
	var timestamp_str := str(int(Time.get_unix_time_from_system())).sha256_text()
	var boundary := "FormBoundary%s" % [timestamp_str]
	
	# 表頭
	var headers := [
		("Content-Type: multipart/form-data; boundary=%s" % [boundary])
	]
	
	# 建立 送出內容
	var body := PackedByteArray()
	body.append_array(("\r\n--%s\r\n" % [boundary]).to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" % [file_name]).to_utf8_buffer())
	body.append_array(("Content-Type: %s\r\n\r\n" % [content_type]).to_utf8_buffer())
	body.append_array(content)
	body.append_array(("\r\n--%s--\r\n" % [boundary]).to_utf8_buffer())
	
	# 送出請求
	var error := request.request_raw(url, headers, HTTPClient.METHOD_POST, body)
	
	# 若 沒有成功送出
	if error != OK :
		push_error("An error occurred in the HTTP request : %s" % [error])
	# 若 成功送出 則 等待 等候器
	else :
		await signal_waiter.until_emit()
	
	return response_ref[0]

## POST (帶dict資料) 
func post_data (url: String, data: Dictionary, opt := {}) :
	var invoker = UREQ.acc(&"Uzil:invoker")
	
	var post_result = null
	
	var http_node : Node = UREQ.acc(&"Uzil:Uzil").request_node("Http")
	
	# 重送延遲
	var resend_delay_msec : int = 100
	if opt.has("resend_delay") :
		resend_delay_msec = opt["resend_delay"]
	
	# 重送次數
	var resend_times : int = 0
	if opt.has("resend_times") :
		resend_times = opt["resend_times"]
	
	# 資料
	var data_str : String = JSON.stringify(data)
	
	# 當 尚有 重送次數
	while resend_times != 0 : 
		resend_times -= 1
		
		# 送出並等候
		var response : Dictionary = await self._post_data(http_node, url, data_str)
		
		# 若 無錯誤 則 設置結果並跳出
		if response.err == OK : 
			post_result = response.res
			break
		
		# 等候延遲後 重送
		await invoker.wait(resend_delay_msec)
	
	# 返回結果
	return post_result

# Private ====================

func _post_data (http_node: Node, url: String, data_str: String) -> Dictionary :
	# 等候器
	var signal_waiter : RefCounted = UREQ.acc(&"Uzil:Util").async.SignalWaiter.new()
	# 表投
	var headers := ["Content-Type: application/json"]
	# 結果
	var response := {
		"err": OK,
		"res": null,
	}
	
	# 建立請求
	var request := HTTPRequest.new()
	request.request_completed.connect(func(_result, _response_code, _headers, _body):
		# 若 成功
		if _result == HTTPRequest.RESULT_SUCCESS :
			# 取出並設置結果
			response.res = _body.get_string_from_utf8()
			# 通知等候器
			signal_waiter.emit()
			#G.print("response %s" % response.res)
		#else :
			#G.print("not connected to server")
			
		http_node.remove_child(request)
		request.queue_free()
	)
	http_node.add_child(request)
	
	# 送出請求
	var error := request.request(url, headers, HTTPClient.METHOD_POST, data_str)
	# 若 沒有成功送出
	if error != OK :
		push_error("An error occurred in the HTTP request : %s" % [error])
		response.err = FAILED
	# 若成功送出 則 等待 等候器
	else :
		await signal_waiter.until_emit()
	
	return response
