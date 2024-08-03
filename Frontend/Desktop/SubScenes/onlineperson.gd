extends Button

@onready var image = $TextureRect

@export var id:String
@export var world:String

func setuser():
	var user = await ApiCvrHttp.GetUserById(id)
	
	tooltip_text = user.data.name
	image.texture = await Cache.get_image(user.data.imageUrl, Cache.ITEM_TYPES.USER, id)


func _on_pressed():
	pass # Replace with function body.
