extends HTTPRequest

const cdnaddr : String = 'https://files.abidata.io/'

const ITEM_TYPES: Dictionary = {
	USER = 'user_images/',
	AVATAR = 'user_content/avatars/',
	WORLD = 'user_content/worlds/',
	PROP = 'user_content/spawnables/'
}

var cachedir = 'user://CVRY/cache/'

var buffer

func _ready():
	if !DirAccess.dir_exists_absolute(cachedir):
		DirAccess.make_dir_recursive_absolute(cachedir)

func get_image(URL:String, TYPE:String):
	#prep image data
	var imagename = URL.trim_prefix(cdnaddr + TYPE)
	var imagemeta = imagename.trim_suffix('png') + 'meta'
	print_debug("Fetching image: " + imagename)
	
	#get hash from header
	request(URL, [Utils.GetUserAgent], HTTPClient.METHOD_HEAD)
	var header = await request_completed
	var headerhash = header[ApiCvrHttp.PACKED_RESPONSE.HEADERS][9]
	print_debug("Fetching image hash")
	
	#check existing hash against server's 
	if FileAccess.file_exists(cachedir + imagemeta):
		#if meta exists read and compare. download and set new hash as needed
		var hashfile =  FileAccess.open(cachedir + imagemeta, FileAccess.READ_WRITE)
		var existhash = hashfile.get_as_text(true)
		hashfile.close()
		
		if existhash != headerhash:
			hashfile = FileAccess.open(cachedir + imagemeta, FileAccess.WRITE_READ)
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
	request(url, [Utils.GetUserAgent], HTTPClient.METHOD_GET,)
	var reply : Array = await request_completed
	buffer = reply[ApiCvrHttp.PACKED_RESPONSE.DATA]
	imagefile.store_buffer(buffer)
	return
	

func load_image_from_cache(File:String):
	var image = Image.new()
	print_debug('Loading image from file')
	await image.load(File)
	var texture = ImageTexture.create_from_image(image)
	return texture
	

func load_image_from_buffer():
	var image = Image.new()
	print_debug('Loading image from buffer')
	await image.load_png_from_buffer(buffer)
	var texture = ImageTexture.create_from_image(image)
	return texture
