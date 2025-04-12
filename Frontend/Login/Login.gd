extends Control

@onready var emailinput = $VBoxContainer/Email
@onready var passinput = $VBoxContainer/Password
@onready var warn = $VBoxContainer/Label

@onready var tosagree = $VBoxContainer/TOSAgree
@onready var remember =$VBoxContainer/RememberMe

var request:HTTPRequest

func _on_button_pressed():
	if !tosagree.button_pressed:
		warn.text = 'You must agree to the TOS to log in'
		warn.visible = true
		return
	
	request = await ApiCvrHttp.Authenticate(emailinput.text, passinput.text)
	
	var res = await request.request_completed
	request.queue_free()
	
	var response_code = res[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]
	var parsedstring = JSON.parse_string(res[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8())
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
			if remember.button_pressed: LoginInfo.savelogininfo()
			WebSocket.PrepWS()
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
			warn.text = ("Well that was awkward. Something unexpected happened: (%s : %s)" % [response_code, res[ApiCvrHttp.PACKED_RESPONSE.STATUS]]) #while a 403 isn't nessesarily cloudflare it's the most likly in this case
			warn.visible = true
			printerr("Some unexpected error occoured while loging in!")
		
	
