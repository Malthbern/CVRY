extends Panel

@export var Username:String
@export var UUID:String
@export var ImgUrl:String

@onready var pfp = $FriendPFP
@onready var namelabel = $FriendName

func _ready():
	namelabel.text = Username
	pfp.texture = await Cache.get_image(ImgUrl, Cache.ITEM_TYPES.USER, UUID)
