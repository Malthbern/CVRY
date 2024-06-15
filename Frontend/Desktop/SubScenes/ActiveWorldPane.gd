extends Node

#UI items
@onready var worldimage = $"HDteailContainer/World Image"
@onready var namelabel = $HDteailContainer/DetailsContainer/WorldName
@onready var idlabel = $HDteailContainer/DetailsContainer/ID
@onready var countlabel = $HDteailContainer/DetailsContainer/PlayerCountContainer/PlayerCount
@onready var localimage = $HDteailContainer/DetailsContainer/Locale

@export var playercount:int
@export var wid:String
@export var Name:String
@export var imgurl:String
@export var locale:int

func applyworld():
	countlabel.text = "%s" % [playercount]
	idlabel.text = wid
	namelabel.text = Name
	worldimage.texture = await Cache.get_image(imgurl, Cache.ITEM_TYPES.WORLD, wid)


func _on_details_pressed():
	pass # Replace with function body.
