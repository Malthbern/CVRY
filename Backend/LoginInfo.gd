extends Node

const SAVE_DIR = "user://CVRY/"
const SAVE_NAME = "login.json"

@export var email:String
@export var username:String
@export var password:String
@export var userid:String
@export var logintoken:String


func savelogininfo():
	var dict:Dictionary = {
		'email' : email,
		'username' : username,
		'password' : password,
		'userid' : userid,
		'logintoken' : logintoken
	}
	
	if !FileAccess.file_exists(SAVE_DIR+SAVE_NAME):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	SaveCrypto.encrypt_and_save(dict, SAVE_DIR+SAVE_NAME) #this is obfuscated to avoid easy decryption by bad actors
	

func _ready():
	print_debug('Getting login info ready')
	var json_return = SaveCrypto.decrypt_and_read(SAVE_DIR+SAVE_NAME)
	if json_return == null:
		printerr("Something when horriably wrong!: %s" % [json_return])
		get_tree().quit()
		return #just in case, we dont want to go further
	elif json_return is String && json_return == "new":
		FrontStart.loadUI('Login')
		return
	
	email = json_return.email
	username = json_return.username
	password = json_return.password
	logintoken = json_return.logintoken
	print_debug("Login details decrypted and loaded")


#contents of "res://Backend/savecrypto.gd"

#const ekey = 'PUT SOME PASSWORD HERE'
#
#func encrypt_and_save(Data:Dictionary, Path:String):
#	var file = FileAccess.open_encrypted_with_pass(Path, FileAccess.WRITE, ekey)
#	if file == null:
#		print(FileAccess.get_open_error())
#		file.close()
#		return
#	
#	var json_string = JSON.stringify(Data, "\t")
#	
#	file.store_string(json_string)
#	file.close()
#	return
#
#func decrypt_and_read(Path:String):
#	print_debug('Decrypting and reading login info')
#	if FileAccess.file_exists(Path):
#		var file = FileAccess.open_encrypted_with_pass(Path, FileAccess.READ, ekey)
#		if file == null:
#			print(FileAccess.get_open_error())
#			return null
#		var content = file.get_as_text()
#		file.close()
#		
#		var data = JSON.parse_string(content)
#		if data == null:
#			printerr("Cannot parse %s as json_string: (%s)" % [Path, content])
#			return null
#		return data
#		
#	else:
#		printerr("Cannot open non-existant file at %s" % [Path])
#		return "new"
#	
