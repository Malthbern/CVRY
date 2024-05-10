extends Control

@onready var emailinput = $VBoxContainer/Email
@onready var passinput = $VBoxContainer/Password

var response

func _on_button_pressed():
	ApiCvrHttp.request_completed.connect(_on_request_completed)
	ApiCvrHttp.Authenticate(2, emailinput.text, passinput.text)
	


func _on_request_completed(result, response_code, headers, body):
	var parsedstring = JSON.parse_string(body.get_string_from_utf8())
	
	match response_code:
		200:
			print_debug("Login successful; Saving info")
			LoginInfo.email = emailinput.text
			LoginInfo.username = parsedstring.data.username
			LoginInfo.password = passinput.text
			LoginInfo.userid = parsedstring.data.userId
			LoginInfo.logintoken = parsedstring.data.accessKey
			LoginInfo.savelogininfo()
		401:
			print_debug("Incorrect Login/Password")
		403:
			print_debug("403: Forbidden")
		_:
			printerr("Some error occoured while loging in")
		
	
