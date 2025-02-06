
# Variable ===================

# GDScript ===================

# Extends ====================

# Interface ==================

# Public =====================

## 簡易上傳檔案
func upload_file_buffer (url: String, file_name: String, content_type: String, content: PackedByteArray) :
	return await self.post_form(url, {
		"file":{
			"file_name": file_name,
			"content_type": content_type,
			"content": content,
		}
	})

## POST 發送表單
func post_form (url: String, form_dict: Dictionary, opts := {}) :
	
	var timestamp_str := str(int(Time.get_unix_time_from_system())).sha256_text()
	var boundary := "FormBoundary%s" % [timestamp_str]
	
	# 表頭
	var headers := [
		("Content-Type: multipart/form-data; boundary=%s" % [boundary])
	]
	
	var boundary_buffer : PackedByteArray = ("\r\n--%s\r\n" % [boundary]).to_utf8_buffer()
	var next_line_buffer : PackedByteArray = ("\r\n").to_utf8_buffer()
	
	# 建立 送出內容
	var body := PackedByteArray()
	for name in form_dict :
		var item = form_dict[name]
		
		var disposition := "Content-Disposition: form-data; name=\"%s\"" % [name]
		var content_type := ""
		var content = item
		
		if typeof(item) == TYPE_DICTIONARY :
			
			if item.has("file_name") :
				disposition += "; filename=\"%s\"" % [item["file_name"]]
			
			if item.has("content_type") :
				content_type = "Content-Type: %s" % [item["content_type"]]
			
			if item.has("content") :
				content = item["content"]
		
		if typeof(content) != TYPE_PACKED_BYTE_ARRAY :
			content = str(content).to_utf8_buffer()
		
		body.append_array(boundary_buffer)
		
		body.append_array(disposition.to_utf8_buffer())
		body.append_array(next_line_buffer)
		
		if not content_type.is_empty() :
			body.append_array(content_type.to_utf8_buffer())
			body.append_array(next_line_buffer)
		
		body.append_array(next_line_buffer)
		body.append_array(content)
	
	body.append_array(("\r\n--%s--\r\n" % [boundary]).to_utf8_buffer())
	
	return await self._do_post(func(http_node):
		# 等候器
		var signal_waiter : RefCounted = UREQ.acc(&"Uzil:Util").async.SignalWaiter.new()
		# 結果
		var response := {
			"err": HTTPRequest.RESULT_SUCCESS,
			"res": null,
		}
		
		# 建立請求
		var request := HTTPRequest.new()
		request.request_completed.connect(func(_result, _response_code, _headers, _body):
			# 若 請求成功
			if _result == HTTPRequest.RESULT_SUCCESS :
				# 取出結果
				response.res = _body.get_string_from_utf8()
			else :
				response.err = _result
				G.print("http request not success : %s" % [_result])
			
			http_node.remove_child(request)
			request.queue_free()
			
			# 通知 等候器
			signal_waiter.emit()
		)
		http_node.add_child(request)
		
		# 送出請求
		var error := request.request_raw(url, headers, HTTPClient.METHOD_POST, body)
		
		# 若 沒有成功送出
		if error != OK :
			push_error("An error occurred in the HTTP request : %s" % [error])
			response.err = error
		# 若 成功送出 則 等待 等候器
		else :
			await signal_waiter.until_emit()
		
		return response
	, opts)
	

## POST dict資料
func post_data (url: String, data: Dictionary, opts := {}) :
	# 表頭
	var headers := ["Content-Type: application/json"]
	# 資料
	var data_str : String = JSON.stringify(data)
	# 超時
	var timeout := 10
	if opts.has("timeout") :
		timeout = opts["timeout"]
	
	# 送出
	var post_result = await self._do_post(func(http_node):
		
		# 等候器
		var signal_waiter : RefCounted = UREQ.acc(&"Uzil:Util").async.SignalWaiter.new()
		# 結果
		var response := {
			"err": HTTPRequest.RESULT_SUCCESS,
			"res": null,
		}
		
		# 建立請求
		var request := HTTPRequest.new()
		request.timeout = timeout
		
		# 當完成
		request.request_completed.connect(func(_result, _response_code, _headers, _body):
			G.print("http : response %s" % response.res)
			# 若 成功
			if _result == HTTPRequest.RESULT_SUCCESS :
				# 取出並設置結果
				response.res = _body.get_string_from_utf8()
				
			else :
				response.err = _result
				G.print("http request not success : %s" % [_result])
			
			http_node.remove_child(request)
			request.queue_free()
			
			# 通知等候器
			signal_waiter.emit()
		)
		http_node.add_child(request)
		
		# 送出請求
		G.print("http : send request : %s" % [data_str])
		var error := request.request(url, headers, HTTPClient.METHOD_POST, data_str)
		# 若 沒有成功送出
		if error != OK :
			push_error("An error occurred in the HTTP request : %s" % [error])
			response.err = FAILED
		# 若成功送出 則 等待 等候器
		else :
			await signal_waiter.until_emit()
		
		return response
	, opts)
	# 返回結果
	return post_result

# Private ====================

func _do_post (req_fn: Callable, opts := {}) :
	var invoker = UREQ.acc(&"Uzil:invoker")
	
	var post_result = null
	
	var http_node : Node = UREQ.acc(&"Uzil:Uzil").request_node("Http")
	
	# 重送延遲
	var resend_delay_msec : int = 100
	if opts.has("resend_delay") :
		resend_delay_msec = opts["resend_delay"]
	
	# 重送次數
	var resend_times : int = 1
	if opts.has("resend_times") :
		resend_times = opts["resend_times"]
	
	# 當 尚有 重送次數
	while resend_times != 0 : 
		if resend_times > 0 :
			resend_times -= 1
		
		# 送出並等候
		var response : Dictionary = await req_fn.call(http_node)
		
		# 若 無錯誤 則 設置結果並跳出
		if response.err == HTTPRequest.RESULT_SUCCESS : 
			post_result = response.res
			break
		
		# 等候延遲後 重送
		await invoker.wait(resend_delay_msec)
		
		G.print("http resend because err : %s" % [response.err])
	
	# 返回結果
	return post_result
