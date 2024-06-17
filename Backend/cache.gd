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
	#default image
	if URL == 'https://files.abidata.io/user_images/00default.png':
		push_warning('Avatar is default')
		return default
	
	#prep image data
	var imagename = URL.trim_prefix(cdnaddr + TYPE)
	imagename = imagename.trim_prefix(AssetId) #this is to account for a weird instance where the image does not have the asset/userid in it
	var imagemeta = imagename.trim_suffix('png') + 'meta'
	print_debug("Fetching image: " + imagename)
	
	#get hash from header
	var headreq = HEAD(URL)
	var header = await headreq.request_completed
	headreq.queue_free()
	if header[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE] != 200:
		printerr('An error occoured while requesting an image hash: (%s)' % [header[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]]) 
		return errorimg
	var headerhash = header[ApiCvrHttp.PACKED_RESPONSE.HEADERS][9]
	print_debug("Fetching image hash")
	
	#check existing hash against server's 
	if FileAccess.file_exists(cachedir + imagemeta):
		#if meta exists read and compare. download and set new hash as needed
		var hashfile =  FileAccess.open(cachedir + imagemeta, FileAccess.READ_WRITE)
		if hashfile == null:
			printerr('An error occoured while loading an image meta: (%s)' % [FileAccess.get_open_error()])
			return errorimg
		var existhash = hashfile.get_as_text(true)
		hashfile.close()
		
		if existhash != headerhash:
			hashfile = FileAccess.open(cachedir + imagemeta, FileAccess.WRITE_READ)
			if hashfile == null:
				printerr('An error occoured while loading an image meta: (%s)' % [FileAccess.get_open_error()])
				return errorimg
			print_debug("Hashes do not match: existing: " + existhash + ' cdn: ' + headerhash)
			await download_image(URL, cachedir + imagename)
			print_debug("Storeing new hash in meta file at: " + cachedir + imagemeta)
			hashfile.store_string(headerhash)
			hashfile.close()
			print_debug('Downloading new image from: ' + URL)
			download_image(URL, cachedir + imagename)
			return await load_image_from_buffer()
		
	elif !FileAccess.file_exists(cachedir + imagemeta):
		#assume if meta is missing so is image
		print_debug('New image or missing meta')
		var newhash = FileAccess.open(cachedir + imagemeta, FileAccess.WRITE_READ)
		if newhash == null:
				printerr('An error occoured while creating an image meta:(%s) (%s)' % [cachedir + imagemeta ,FileAccess.get_open_error()])
				return errorimg
		print_debug("Storeing new hash in meta file at: " + cachedir + imagemeta)
		newhash.store_string(headerhash)
		newhash.close()
		print_debug('Downloading new image from: ' + URL)
		await download_image(URL, cachedir + imagename)
		print_debug("Fetching image from file")
		return await load_image_from_buffer()
	
	print_debug('Hash exists and matches server')
	return await load_image_from_cache(cachedir + imagename)
	

func download_image(url:String, path:String):
	var imagefile = FileAccess.open(path, FileAccess.WRITE_READ)
	var imgget = IMG_GET(url)
	var reply = await imgget.request_completed
	imgget.queue_free()
	if reply[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE] != 200:
		printerr('An error occured ehile trying to fetch %s (%s)' % [url, reply[ApiCvrHttp.PACKED_RESPONSE.RESPONSE_CODE]])
		return errorimg
	buffer = reply[ApiCvrHttp.PACKED_RESPONSE.DATA]
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
				print_debug('Updating online friend %s' % [friend.Id])
				Online_Friends[i] = friend
			i += 1
		if !found:
			print_debug('Friend %s wasnt found in online list appending' % [friend.Id])
			Online_Friends.append(friend)
	
	i = 0
	for friend in Online_Friends:
		if !friend.IsOnline:
			Online_Friends_Updated.emit()
			print_debug('Purging offline friend %s' % [friend.Id])
			Online_Friends.remove_at(i)
		i += 1
	Online_Friends_Updated.emit() # We have to duplicate the array due to how godot handles variables
