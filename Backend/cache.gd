extends HTTPRequest

const cdnaddr : String = 'https://files.abidata.io/'

const ITEM_TYPES: Dictionary = {
	USER = 'user_images/',
	AVATAR = 'user_content/avatars/',
	WORLD = 'user_content/worlds/',
	PROP = 'user_content/spawnables/'
}

var cachedir = 'user://CVRY/cache'

func _ready():
	if !DirAccess.dir_exists_absolute(cachedir):
		DirAccess.make_dir_recursive_absolute(cachedir)

func get_image(URL:String, TYPE:String):
	#prep image data
	var imagename = URL.trim_prefix(cdnaddr + TYPE)
	var imagemeta = imagename.trim_suffix('png') + 'meta'
	
	#get hash from header
	request(URL, [Utils.GetUserAgent], HTTPClient.METHOD_HEAD)
	var header = await request_completed
	var hash = header[ApiCvrHttp.PACKED_RESPONSE.HEADERS][9]
	
