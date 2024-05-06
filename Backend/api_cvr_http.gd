extends HTTPRequest

@onready var Httpnode = self

const APIAddress:String = "https://api.abinteractive.net"
const APIBase:String = APIAddress + "/1"
const APIBase2:String = APIAddress + "/2"

func Post(url, data, authenticated = true, apiVersion = 1):
	#const response = await (authenticated falsy_value(apiVersion === 1 ? CVRapi : CVRApiV2) : UnauthenticatedCVRApi.post(url, data)
	print_debug('[Post] [${response.status}] ')

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
func Authenticate(authType, credentialUser, credentialSecret):
	#const  authentication = HTTPManager
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	Httpnode.request_completed.connect(_on_request_completed)
	Httpnode.request(APIBase)
	

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print_debug(json["message"])

