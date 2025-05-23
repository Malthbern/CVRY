extends Node

const SAVE_DIR = "user://CVRY/"
const SAVE_NAME = "login.json"

@export var email:String
@export var username:String
@export var password:String
@export var userid:String
@export var logintoken:String
@export var UserId:String
@export var loginvalid : bool = false

var request:HTTPRequest

func savelogininfo():
	var dict:Dictionary = {
		'email' : email,
		'username' : username,
		'password' : password,
		'userid' : userid,
		'logintoken' : logintoken
	}
	
	if !DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	SaveCrypto.encrypt_and_save(dict, SAVE_DIR+SAVE_NAME) #this is obfuscated to avoid easy decryption by bad actors
	

func _ready():
	print_debug('Getting login info ready')
	var json_return = SaveCrypto.decrypt_and_read(SAVE_DIR+SAVE_NAME)
	if json_return == null:
		printerr("Could not open login file pushing to login screen")
		FrontStart.loadUI('Login')
		return
		
	elif json_return is String && json_return == "new":
		FrontStart.loadUI('Login')
		return
	
	email = json_return.email
	username = json_return.username
	password = json_return.password
	userid = json_return.userid
	logintoken = json_return.logintoken
	print_debug("Login details decrypted and loaded")
	autologin()

func autologin():
	request = await ApiCvrHttp.Authenticate(email, password)
	
	var res = await request.request_completed
	request.queue_free()
	
	var response_code = res[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]
	var parsedstring = JSON.parse_string(res[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8())
	
	match response_code:
		200:
			print_debug("Auto Login successful")
			username = parsedstring.data.username
			logintoken = parsedstring.data.accessKey
			loginvalid = true
			WebSocket.PrepWS()
			FrontStart.loadUI(OS.get_name())
			
		401:
			print_debug("Auto-Login out of date, moving to manual login")
			FrontStart.loadUI('Login')
		403:
			print_debug("403: Forbidden")
		_:
			printerr("Some unexpected error occoured while loging in!")
		
	
