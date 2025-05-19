extends Node

var ekey:String

func _ready():
	if !FileAccess.file_exists('res://parsednonesense.txt'):
		var keyfile = FileAccess.open('res://parsednonesense.txt',FileAccess.WRITE)
		var crypto := Crypto.new()
		var byte_array := crypto.generate_random_bytes(1024)
		keyfile.store_string(byte_array.get_string_from_utf16())
		keyfile.close()
	
	ekey = FileAccess.get_sha256('res://parsednonesense.txt')

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
	print_debug('Decrypting and reading login info')
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
	
