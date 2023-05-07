
## Uzupdater Http 連接
##
## Uzupdater更新器 用來Http下載更新檔的工具元件
##

# Variable ===================

var uzupdater = null

# GDScript ===================

func _init (_uzupdater) :
	self.uzupdater = _uzupdater

# Extends ====================

# Public =====================

## 下載 到 指定位置
func download (url, save_to, on_complete) :
	
#	print("download \"%s\" save to \"%s\"" % [url, save_to])
	var http_request = HTTPRequest.new()
	self.uzupdater.add_child(http_request)
	
	http_request.download_file = save_to
	
	http_request.request_completed.connect(func (result, response_code, headers, body) :
#		print("http.download.request_completed result[%s] response_code[%s]" % [result, response_code])
		self.uzupdater.remove_child(http_request)
		on_complete.call({
			"result": result,
			"response_code": response_code,
			"headers": headers,
			"body":body
		})
	)
	
	var err = http_request.request(url)
	
	if err == OK : err = null
	else : err = error_string(err)
	
	return {"err":err, "req":http_request}

## 發送 請求
func request (url, method:int, data_str, on_complete) :
	var http_request = HTTPRequest.new()
	self.uzupdater.add_child(http_request)
	
	http_request.request_completed.connect(func (result, response_code, headers, body) :
#		print("http.request.request_completed result[%s] response_code[%s]" % [result, response_code])
		self.uzupdater.remove_child(http_request)
		on_complete.call({
			"result": result,
			"response_code": response_code,
			"headers": headers,
			"body":body
		})
	)
	
	var err = http_request.request(url, [], method, data_str)
	
	if err == OK : err = null
	else : err = error_string(err)
	
	return {"err":err, "req":http_request}

## 轉換結果 為 字串
func result_string (httprequest_result_enum) :
	match httprequest_result_enum :
		HTTPRequest.RESULT_SUCCESS:
			return "RESULT_SUCCESS"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "RESULT_CHUNKED_BODY_SIZE_MISMATCH"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "RESULT_CANT_CONNECT"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "RESULT_CANT_RESOLVE"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "RESULT_CONNECTION_ERROR"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "RESULT_TLS_HANDSHAKE_ERROR"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "RESULT_NO_RESPONSE"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "RESULT_BODY_SIZE_LIMIT_EXCEEDED"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "RESULT_BODY_DECOMPRESS_FAILED"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "RESULT_REQUEST_FAILED"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN :
			return "RESULT_DOWNLOAD_FILE_CANT_OPEN "
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR :
			return "RESULT_DOWNLOAD_FILE_WRITE_ERROR "
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED :
			return "RESULT_REDIRECT_LIMIT_REACHED "
		HTTPRequest.RESULT_TIMEOUT :
			return "RESULT_TIMEOUT "
		_ :
			return null

# Private ====================

