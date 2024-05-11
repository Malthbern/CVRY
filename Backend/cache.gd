extends HTTPRequest

const cdnaddr : String = 'https://files.abidata.io/'
const imgs : String = 'user_images/'

var cachedir = 'user://CVRY/cache'

func get_image(ImageID:String):
	ApiCvrHttp.Get('url')
