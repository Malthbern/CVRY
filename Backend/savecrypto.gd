extends Node

const ekey = '488df7f15a0c44246fad51c0f09028108fd83cf88100b643aba584ae5de31c1d'

func encrypt_and_save(Data:Dictionary, Path:String):
	var file = FileAccess.open_encrypted_with_pass(Path, FileAccess.WRITE, ekey)
	if file == null:
		print(FileAccess.get_open_error())
		file.close()
		return
	
	var json_string = JSON.stringify(Data, "\t")
	
	file.store_string(json_string)
	file.close()
	return

func decrypt_and_read(Path:String):
	if FileAccess.file_exists(Path):
		var file = FileAccess.open_encrypted_with_pass(Path, FileAccess.READ, ekey)
		if file == null:
			print(FileAccess.get_open_error())
			return null
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as json_string: (%s)" % [Path, content])
			return null
		return data
		
	else:
		printerr("Cannot open non-existant file at %s" % [Path])
		return "new"
	
