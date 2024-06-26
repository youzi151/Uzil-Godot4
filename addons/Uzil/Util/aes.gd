
## AES加密相關
##
## 處理 AES 的 相關事務
## 

const INT_BYTES_SIZE : int = 8

## 簡易加密 (原始str -密鑰str-> 加密str)
func encrypt_simple (txt: String, key: String, iv := "X1iEs92kcDvJ3Jac") -> String :
	var content : PackedByteArray = []
	var txt_bytes : PackedByteArray = txt.to_utf8_buffer()
	var key_bytes : PackedByteArray = self._str_to_size_fit_bytes(key, 32)
	var iv_bytes : PackedByteArray = self._str_to_size_fit_bytes(iv, 16)
	
	# 補空容量 = (內容容量 + 描述補空容量用的int容量) % 16
	var txt_padding_size : int = 0
	txt_padding_size = 16 - ((txt_bytes.size()+INT_BYTES_SIZE) % 16)
	
	# 添加 描述補空容量的int
	content.append_array(var_to_bytes(txt_padding_size))
	# 添加 補空
	if txt_padding_size > 0 :
		content.resize(content.size() + txt_padding_size)
	# 添加 內容
	content.append_array(txt_bytes)
	
	# 加密
	var aes = AESContext.new()
	aes.start(AESContext.MODE_CBC_ENCRYPT, key_bytes, iv_bytes)
	var encrypted : PackedByteArray = aes.update(content)
	aes.finish()
	
	return encrypted.get_string_from_utf8()

## 簡易解密 (加密str -密鑰str-> 原始str)
func decrypt_simple (encrypted_str: String, key: String, iv := "X1iEs92kcDvJ3Jac") -> String :
	var encrypted : PackedByteArray = encrypted_str.hex_decode()
	var key_bytes : PackedByteArray = self._str_to_size_fit_bytes(key, 32)
	var iv_bytes : PackedByteArray = self._str_to_size_fit_bytes(iv, 16)
	
	# 解密
	var aes = AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, key_bytes, iv_bytes)
	var decrypted : PackedByteArray = aes.update(encrypted)
	aes.finish()
	
	# 取出 描述補空容量的int
	var txt_padding_size_bytes : PackedByteArray = decrypted.slice(0, INT_BYTES_SIZE)
	var txt_padding_size = self._bytes_to_var(txt_padding_size_bytes)
	if txt_padding_size == null : return ""
	
	# 內容 為 描述補空容量的int + 補空容量 以後的位元組
	var result_bytes : PackedByteArray = decrypted.slice(INT_BYTES_SIZE+txt_padding_size)
	return result_bytes.get_string_from_utf8()

## 轉換 字串 為 符合長度 的 位元組
## 為 單向轉換 且 會依照長度裁減或添加額外位元組
func _str_to_size_fit_bytes (txt: String, bytes_count: int) -> PackedByteArray :
	
	var result : PackedByteArray = []
	var bytes : PackedByteArray = var_to_bytes(txt.hash())
	var bytes_size : int = bytes.size()
	var diff : int = bytes_count - bytes_size
	
	# 剛好一致
	if diff == 0 :
		return bytes
		
	# 需要補足
	elif diff > 0 :
		result.append_array(bytes)
		result.resize(bytes_count)
		var cursor : int = 0
		# 循環重複
		for idx in diff :
			result[bytes_size + idx] = bytes[cursor]
			cursor += 1
			if cursor >= bytes_size : cursor = 0
		return result
		
	# 需要裁減
	elif diff < 0 :
		return bytes.slice(0, bytes_count)
	
	return result

func _bytes_to_var (bytes: PackedByteArray) :
	return bytes_to_var(bytes)
