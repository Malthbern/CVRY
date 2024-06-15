extends Node

var Friendbutton = load("res://Frontend/Desktop/SubScenes/onlineperson.tscn")
@onready var friendcontainer = $HDetailContainer/VDetailContainer/ScrollContainer/FlowContainer
@onready var worldlabel = $HDetailContainer/VDetailContainer/Label
@onready var worldimage = $HDetailContainer/TextureRect

@export var IsPermenantPannel:bool = false

var worldname:String
var imagurl:String
var worldid:String

func setworld():
	worldlabel.text = worldname
	worldimage.texture = await Cache.get_image(imagurl, Cache.ITEM_TYPES.WORLD, worldid)
	return

func adduser(user:Dictionary):
	var find = friendcontainer.find_child(user.Id, false, false)
	
	if find != null:
		return
	
	var instance = Friendbutton.instantiate()
	instance.name = user.Id
	instance.id = user.Id
	if user.Instance != null:
		instance.world = user.Instance.Id
	friendcontainer.add_child(instance)
	instance.setuser()

func removeuser(user:Dictionary):
	var find = friendcontainer.find_child(user.Id, false, false)
	
	if !IsPermenantPannel:
		if friendcontainer.get_child_count() == 0: self.queue_free()
	
	if find == null:
		return
	
	if user.Instance != null:
		if user.Instance.Id == self.name:
			return
	elif user.Instance == null && find.world == '':
		return
	
	find.queue_free()
	

