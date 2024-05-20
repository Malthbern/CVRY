extends Node

#UI items
@onready var worldimage = $"World Image"
@onready var namelabel = $WorldName
@onready var idlabel = $ID
@onready var countlabel = $PlayerCount
@onready var localimage = $Locale

@export var playercount:int
@export var wid:String
@export var Name:String
@export var imgurl:String
@export var locale:

func applyworld():
	countlabel.text = "%s" % [playercount]
	idlabel.text = wid
	namelabel.text = Name
	worldimage.texture = await Cache.get_image(imgurl, Cache.ITEM_TYPES.WORLD, wid)


func _on_details_pressed():
	pass # Replace with function body.
