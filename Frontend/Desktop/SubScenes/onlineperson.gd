extends Button

@onready var image = $TextureRect

@export var id:String
@export var world:String

func setuser():
	var req = ApiCvrHttp.GetUserById(id)
	var res = await req.request_completed
	req.queue_free()
	var user = JSON.parse_string(res[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8())
	
	tooltip_text = user.data.name
	image.texture = await Cache.get_image(user.data.imageUrl, Cache.ITEM_TYPES.USER, id)


func _on_pressed():
	pass # Replace with function body.
