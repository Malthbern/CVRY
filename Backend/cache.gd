extends Node

const cdnaddr : String = 'https://files.abidata.io/'

const errorimg = preload("res://Frontend/orange-error-icon-0.png")
const default = preload("res://Frontend/00default.png")

const ITEM_TYPES: Dictionary = {
	USER = 'user_images/',
	AVATAR = 'user_content/avatars/',
	WORLD = 'user_content/worlds/',
	PROP = 'user_content/spawnables/',
	BADGE = 'static_web/Badges/'
}

var cachedir = 'user://CVRY/cache/'

var buffer

var Online_Friends:Array

var OurUserInfo

func _ready():
	if !DirAccess.dir_exists_absolute(cachedir):
		DirAccess.make_dir_recursive_absolute(cachedir)

func HEAD (url:String):
	var http = HTTPRequest.new()
	add_child(http)
	http.name = url
	http.request(url, [Utils.GetUserAgent], HTTPClient.METHOD_HEAD)
	return http

func IMG_GET(url:String):
	var http = HTTPRequest.new()
	add_child(http)
	http.name = url
	http.request(url, [Utils.GetUserAgent], HTTPClient.METHOD_GET)
	return http

func get_image(URL:String, TYPE:String, AssetId:String = ''):
	
	if URL == "https://files.abidata.io/user_images/00default.png":
		return default
		
	var local = get_local_hash(cachedir + AssetId + ".meta")
	
	#We seperate by type for granular control if needed later
	if TYPE == ITEM_TYPES.USER: #Hash is provided in URI
		var remote = URL.trim_prefix(cdnaddr + TYPE + AssetId + "-")
		remote = remote.trim_suffix(".png")
		
		if local is String:
			if local == remote:
				return await load_image_from_cache(cachedir + AssetId + ".png")
		
		save_local_hash(cachedir + AssetId + ".meta", remote)
		if (await download_image(URL, cachedir + AssetId + ".png") == errorimg):
			return errorimg
		return await load_image_from_buffer()
	
#	if TYPE == ITEM_TYPES.WORLD: #Worlds dont provide a hash in the URI, so we just always download
#		await download_image(URL)
#		return await load_image_from_buffer()
#	
#	if TYPE == ITEM_TYPES.AVATAR:
#		await download_image(URL)
#		return await load_image_from_buffer()
#	
#	if TYPE == ITEM_TYPES.PROP:
#		await download_image(URL)
#		return await load_image_from_buffer()
	
	if TYPE == ITEM_TYPES.BADGE: #These Tend to not change so we will cache without hash
		var file = URL.trim_prefix(cdnaddr + TYPE)
		if FileAccess.file_exists(cachedir + file):
			return await load_image_from_cache(cachedir + file)
		await download_image(URL, cachedir + file)
		return await load_image_from_buffer()
	
	#default behavior is to download from server and use etag as image hash
	#this is bad but theres no other choice if i want to cache everything
	
	var remote = await get_remote_hash(URL)
	
	if local is String:
		if local == remote:
			return await load_image_from_cache(cachedir + AssetId + ".png")
	
	save_local_hash(cachedir + AssetId + ".meta", remote)
	if (await download_image(URL, cachedir + AssetId + ".png") == errorimg):
		return errorimg
	return await load_image_from_buffer()


func download_image(url:String, path = null):
	var imgget = IMG_GET(url)
	var reply = await imgget.request_completed
	imgget.queue_free()
	if reply[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE] != 200:
		printerr('An error occured while trying to fetch %s (%s)' % [url, reply[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]])
		return errorimg
	buffer = reply[ApiCvrHttp.PACKED_RESPONSE.DATA]
	if path is String:
		var imagefile = FileAccess.open(path, FileAccess.WRITE_READ)
		imagefile.store_buffer(buffer)
	return
	

func load_image_from_cache(File:String):
	var image = Image.new()
	print_debug('Loading image from file')
	await image.load(File)
	var texture = ImageTexture.create_from_image(image)
	if texture == null:
		printerr('Something happened while loading an image from cache: ' + File)
		return errorimg
	return texture

func load_image_from_buffer():
	var image = Image.new()
	print_debug('Loading image from buffer')
	await image.load_png_from_buffer(buffer)
	var texture = ImageTexture.create_from_image(image)
	if texture == null:
		printerr('Something happened while loading an image from buffer: ' + ''.join(buffer))
		return errorimg
	return texture

func get_remote_hash(url:String):
	var head = HEAD(url)
	var request = await head.request_completed
	
	if request[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE] == 200:
		var headers = request[ApiCvrHttp.PACKED_RESPONSE.HEADERS]
		return headers[9].trim_prefix("ETag: ")
	

func get_local_hash(Path:String):
	var file
	var local
	if FileAccess.file_exists(Path):
		file = FileAccess.open(Path,FileAccess.READ)
		local = file.get_as_text()
		file.close()
		return local
	return false

func save_local_hash(Path:String, Content:String):
	pass
	var file = FileAccess.open(Path,FileAccess.WRITE_READ)
	file.store_string(Content)
	file.close()

#Friend Location cacher
#God only hopes this changes at some point

signal Online_Friends_Updated()

func update_online_friends(packet:Array):
	print_debug('Updating online friends')
	
	if Online_Friends.size() == 0:
		print_debug('Online Friends was empty... populating')
		Online_Friends = packet
		Online_Friends_Updated.emit() # We have to duplicate the array due to how godot handles variables
		return
	
	var i:int = 0
	for friend in packet:
		var found = false
		for online in Online_Friends:
			if online.Id == friend.Id:
				found = true
				print_debug('Updating online friend: %s' % [friend.Id])
				Online_Friends[i] = friend
			i += 1
		if !found:
			print_debug('Friend wasnt found in online list. appending: %s' % [friend.Id])
			Online_Friends.append(friend)
	
	i = 0
	for friend in Online_Friends:
		if !friend.IsOnline:
			Online_Friends_Updated.emit()
			print_debug('Purging offline friend: %s' % [friend.Id])
			Online_Friends.remove_at(i)
		i += 1
	Online_Friends_Updated.emit() # We have to duplicate the array due to how godot handles variables

func get_our_user_info() -> void:
	OurUserInfo = await ApiCvrHttp.GetUserById(LoginInfo.userid)
