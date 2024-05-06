extends Node

const SAVE_DIR = "user://CVRY/"
const SAVE_NAME = "login.json"

@export var email:String
@export var username:String
@export var password:String
@export var logintoken:String


func savelogininfo():
	var dict:Dictionary = {
		'email' : email,
		'username' : username,
		'password' : password,
		'logintoken' : logintoken
	}
	
	SaveCrypto.encrypt_and_save(dict, SAVE_DIR+SAVE_NAME) #this is obfuscated to avoid easy decryption by bad actors
	

func _ready():
	var json_return = SaveCrypto.decrypt_and_read(SAVE_DIR+SAVE_NAME)
	if json_return == null:
		printerr("Something when horriably wrong!: %s" % [json_return])
		get_tree().quit()
		return #just in case, we dont want to go further
	elif json_return == "new":
		
	
	email = json_return.email
	username = json_return.username
	password = json_return.password
	logintoken = json_return.logintoken
	print_debug("Login details decrypted and loaded")
