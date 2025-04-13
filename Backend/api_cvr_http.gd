extends Node

const APIAddress:String = "https://api.abinteractive.net"

#get and post web functions

func Get(url, authenticated = true, apiVersion = 1):
	# This looks awful but i cant find a better way of doing it
	var headers: PackedStringArray = [
		"accept: application/json",
		"Content-Type: application/json",
		Utils.GetUserAgent,
		'Username: ' + LoginInfo.username,
		'AccessKey: ' + LoginInfo.logintoken,
		'MatureContentDlc: true',
		'Platform: pc_standalone',
		'CompatibleVersions: 0,1,2'
	]
	
	var http = HTTPRequest.new()
	add_child(http)
	http.name = url
	http.request(APIAddress +'/%s' % [apiVersion] + url, headers, HTTPClient.METHOD_GET)
	return http
	

func Post(url, data, authenticated = true, apiVersion = 1):
	var headers: PackedStringArray
	if authenticated == true:
		headers = [
		"accept: application/json",
		"Content-Type: application/json",
		Utils.GetUserAgent,
		'Username: ' + LoginInfo.user,
		'AccessKey: ' + LoginInfo.logintoken,
		'MatureContentDlc: true',
		'Platform: pc_standalone',
		'CompatibleVersions: 0,1,2'
		]
	else:
		headers = ["accept: application/json", "Content-Type: application/json", Utils.GetUserAgent,]
	
	var http = HTTPRequest.new()
	add_child(http)
	http.name = url
	http.request(APIAddress +'/%s' % [apiVersion] + url + '?acceptTos=false', headers, HTTPClient.METHOD_POST, JSON.stringify(data, '', false, true))
	return http

#api constants
const PACKED_RESPONSE : Dictionary = {
	STATUS = 0,
	RESPONSE_CODE = 1,
	HEADERS = 2,
	DATA = 3
}

const CATEGORY_TYPES : Dictionary = {
	AVATARS = 'Avatars',
	USER = 'User',
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

@export var AuthenticatedHeaders : Dictionary = {
	Username = 'placeholder',
	AccessKey = 'placeholder',
	CompatibleVersions = '0,1,2'
}

#API endpoints

#authenticate
func Authenticate(credentialUser:String, credentialSecret:String, Authtype:int = AuthMethod.PASSWORD):
	
	var authdata : Dictionary = {
		username = credentialUser,
		password = credentialSecret,
		authType = Authtype
	}
	
	return await Post('/users/auth', authdata, false)
	

#get and set functions

#stats
func GetUserStats(): return await parse_response(Get('/public/userstats',false))

#friends
func GetMyFriends(): return await parse_response(Get('/friends'))
func GetMyFriendRequests(): return await parse_response(Get('/friends/requests'))

#users
func GetUserById(id:String): return await parse_response(Get('/users/' + id))
func GetUserPublicAvatars(id:String): return await parse_response(Get('/users/' + id + '/avatars'))
func GetUserPublicWorlds(id:String): return await parse_response(Get('/users/' + id + '/worlds'))
func GetUserPublicProps(id:String): return await parse_response(Get('/users/' + id + '/spawnables'))
func SetFriendNote(id:String , usernote:String): return Post('/users/' + id + 'note', {note = usernote})

#avatars
func GetMyAvatars(): return  await parse_response(Get('/avatars'))
func GetAvatarById(id:String): return await parse_response(Get('/avatars/' + id))

#categorys
#get
func GetCategories(): return await parse_response(Get('/categories'))
#set
func SetCategories(type:String, id:String, categoryIds:PackedStringArray):
	var response : Array = Post('/categories/assign', {Uuid = id, CategoryType = type, Categories = categoryIds})
	return JSON.parse_string(response[PACKED_RESPONSE.DATA].get_string_from_utf8())
#functions for types
func SetAvatarCategories(avatarId:String, categoryIds:PackedStringArray): SetCategories(CATEGORY_TYPES.AVATARS, avatarId, categoryIds)
func SetFriendCategories(friendId:String, categoryIds:PackedStringArray): SetCategories(CATEGORY_TYPES.FRIENDS, friendId, categoryIds)
func SetPropCategories(propId:String, categoryIds:PackedStringArray): SetCategories(CATEGORY_TYPES.PROPS, propId, categoryIds)
func SetWorldCategories(worldId:String, categoryIds:PackedStringArray): SetCategories(CATEGORY_TYPES.WORLDS, worldId, categoryIds)

#worlds
func GetWorldById(id:String): return await parse_response(Get('/worlds/' + id))
func GetWorldMetsById(id:String): return await parse_response(Get('/worlds/' + id + '/meta'))
func GetWorldsByCategory(id:String): return await parse_response(Get('/worlds/list/' + id + '?page=0&direction=0', true, 2))
func SetWorldAsHome(id:String): return await parse_response(Get('/worlds/' + id + '/sethome'))

#props
func GetProps(): return await parse_response(Get('/spawnables'))
func GetPropById(id:String): return await parse_response(Get('/spawnables/' + id))

#instances
func GetInstanceById(id:String): return await parse_response(Get('/instances/' + id))

#search
func Search(term:String): return await parse_response(Get('/search/' + term))

#function to streamline requests
func parse_response(Get_Function:HTTPRequest):
	var tx = await Get_Function.request_completed
	Get_Function.queue_free()
	if tx[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE] != 200:
		printerr("HTTP Error: failed with code %s Details: %s" % [tx[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8(), tx[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]])
		return tx[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]
	return JSON.parse_string(tx[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8())
