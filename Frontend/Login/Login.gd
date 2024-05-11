extends Control

@onready var emailinput = $VBoxContainer/Email
@onready var passinput = $VBoxContainer/Password
@onready var warn = $VBoxContainer/Label

var response

func _on_button_pressed():
	response = await ApiCvrHttp.Authenticate(emailinput.text, passinput.text)
	var response_code = response[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]
	var parsedstring = JSON.parse_string(response[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8())
	
	match response_code:
		200:
			print_debug("Login successful; Saving info")
			LoginInfo.email = emailinput.text
			LoginInfo.username = parsedstring.data.username
			LoginInfo.password = passinput.text
			LoginInfo.userid = parsedstring.data.userId
			LoginInfo.logintoken = parsedstring.data.accessKey
			LoginInfo.userid = parsedstring.data.userId
			LoginInfo.loginvalid = true
			LoginInfo.savelogininfo()
			FrontStart.loadUI(OS.get_name())
			
		401:
			print_debug("Incorrect Login/Password")
			passinput.text = ""
			warn.text = 'E-Mail/Password is incorrect, please try again.'
			warn.visible = true
		403:
			warn.text = "Woah... Slow down there! Cloudflare thinks you're spam (403 Forbidden)" #while a 403 isn't nessesarily cloudflare it's the most likly in this case
			warn.visible = true
			print_debug("403: Forbidden")
		_:
			warn.text = ("Well that was awkward. Something unexpected happened: (%s : %s)" % [response_code, response[ApiCvrHttp.PACKED_RESPONSE.STATUS]]) #while a 403 isn't nessesarily cloudflare it's the most likly in this case
			warn.visible = true
			printerr("Some unexpected error occoured while loging in!")
		
	
