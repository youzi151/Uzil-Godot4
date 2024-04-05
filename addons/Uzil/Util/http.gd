
# Variable ===================

# GDScript ===================

func _init () :
	pass

# Extends ====================

# Interface ==================

# Public =====================

## 上傳檔案
func upload_file_buffer (url : String, file_name : String, content_type : String, content : PackedByteArray) :
	
	var http_node : Node = UREQ.acc("Uzil", "Uzil").request_node("Http")
	
	var request := HTTPRequest.new()
	request.request_completed.connect(func(_result, _response_code, _headers, _body):
		if _response_code == HTTPClient.RESPONSE_OK:
			var response = str_to_var(_body.get_string_from_utf8())
			G.print("response %s" % response)
		elif _response_code == HTTPClient.STATUS_DISCONNECTED:
			G.print("not connected to server")
		http_node.remove_child(request)
		request.queue_free()
	)
	http_node.add_child(request)
	
	var timestamp_str := str(int(Time.get_unix_time_from_system())).sha256_text()
	var boundary := "FormBoundary%s" % [timestamp_str]
	
	var body := PackedByteArray()
	body.append_array(("\r\n--%s\r\n" % [boundary]).to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" % [file_name]).to_utf8_buffer())
	body.append_array(("Content-Type: %s\r\n\r\n" % [content_type]).to_utf8_buffer())
	body.append_array(content)
	body.append_array(("\r\n--%s--\r\n" % [boundary]).to_utf8_buffer())

	var headers := [
		("Content-Type: multipart/form-data; boundary=%s" % [boundary])
	]
	var error := request.request_raw(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("An error occurred in the HTTP request : %s" % [error])
		
	await request.request_completed

# Private ====================

