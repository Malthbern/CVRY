extends Panel

@export var ObjectName:String
@export var UUID:String
@export var ImgUrl:String
@export var ObjectType:String

@onready var pfp = $FriendPFP
@onready var namelabel = $FriendName

func _ready():
	namelabel.text = ObjectName
	pfp.texture = await Cache.get_image(ImgUrl, ObjectType, UUID)


func _on_details_pressed() -> void:
	pass # Replace with function body.
