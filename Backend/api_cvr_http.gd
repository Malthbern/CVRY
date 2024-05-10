extends HTTPRequest

const APIAddress:String = "https://api.abinteractive.net"
const APIBase:String = APIAddress + "/1"
const APIBase2:String = APIAddress + "/2"

func Post(url, data, authenticated = true, apiVersion = 1):
	var headers: PackedStringArray = ["accept: application/json", "Content-Type: application/json", Utils.GetUserAgent]
	var responsecode
	if apiVersion == 1:
		print_debug("Sending: " + JSON.stringify(data, "\t", false) + " to " + APIBase+url)
		request_completed.connect(_on_request_completed)
		request(APIBase+url+'?acceptTos=false', headers, HTTPClient.METHOD_POST, JSON.stringify(data, "\t", false, true))
		
	

func _on_request_completed(result, response_code, headers, body):
	var parsedstring = JSON.parse_string(body.get_string_from_utf8())
	
	print_debug('Response: %s' % [response_code]) 
	print_debug(parsedstring.message)
	print_debug(JSON.stringify(headers, "\t", false))
	

#api constants
const CATEGORY_TYPES : Dictionary = {
	AVATARS = 'Avatars',
	FRIENDS = 'Friends',
	PROPS = 'Props',
	WORLDS = 'Worlds',
}

const AuthMethod : Dictionary = {
	ACCESS_KEY = 1,
	PASSWORD = 2,
}

const PrivacyLevel : Dictionary = {
	Public = 0,
	FriendsOfFriends = 1,
	Friends = 2,
	Group = 3,
	EveryoneCanInvite = 4,
	OwnerMustInvite = 5,
}
@export var PrivacyLevels = PrivacyLevel

#API endpoints

#authenticate
func Authenticate(Authtype:int, credentialUser:String, credentialSecret:String):
	var auth
	
	var authdata : Dictionary = {
		username = credentialUser,
		password = credentialSecret,
		authType = Authtype
	}
	Post('/users/auth', authdata, false)
	
