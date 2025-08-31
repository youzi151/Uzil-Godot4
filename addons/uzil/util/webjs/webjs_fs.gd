
var js = null

func _init (_js) :
	self.js = _js

func exists (path: String) :
	var res = await self.js.invoke("fsExist", [path])
	return res if res != null else false

func read (path: String) :
	var base64str = await self.js.invoke("fsRead", [path])
	return Marshalls.base64_to_raw(base64str)

func write (path: String, buffer: PackedByteArray) :
	return await self.js.invoke("fsWrite", [path, Marshalls.raw_to_base64(buffer)])

func remove (path: String) :
	return await self.js.invoke("fsRemove", [path])
