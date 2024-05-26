extends Node

var Friendbutton = load("res://Frontend/Desktop/SubScenes/onlineperson.tscn")
@onready var friendcontainer = $ScrollContainer/GridContainer
@onready var worldlabel = $Label
@onready var worldimage = $TextureRect

var worldname:String
var imagurl:String
var worldid:String

func setworld():
	worldlabel.text = worldname
	worldimage.texture = await Cache.get_image(imagurl, Cache.ITEM_TYPES.WORLD, worldid)
	return

func adduser(user:Dictionary):
	var finduser = friendcontainer.find_child(user.Id, false, false)
	if finduser != null:
		return
	
	var instance = Friendbutton.instantiate()
	instance.name = user.Id
	instance.id = user.Id
	if user.Instance != null:
		instance.world = user.Instance.Id
	friendcontainer.add_child(instance)
	instance.setuser()

func removeuser(user:Dictionary):
	pass
