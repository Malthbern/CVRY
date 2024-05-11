extends Node

#user
@onready var userlabel = $"HBoxContainer/User+notifications/Profile/VBoxContainer/Username"
@onready var profileimage = $"HBoxContainer/User+notifications/Profile/PlayerProfPic"

#avatar
@onready var avatarlabel = $"HBoxContainer/User+notifications/Profile/VBoxContainer/CurrentAvatar/AvatarName"
@onready var avatarimage = $"HBoxContainer/User+notifications/Profile/VBoxContainer/CurrentAvatar/AvatarImage"

#badge
@onready var badgelabel = $"HBoxContainer/User+notifications/Profile/VBoxContainer/Badge/badgeName"
@onready var badgeimage = $"HBoxContainer/User+notifications/Profile/VBoxContainer/Badge/badgeImage"

#rank
@onready var ranklabel = $"HBoxContainer/User+notifications/Profile/VBoxContainer/Rank/RankName"
@onready var rankimage = $"HBoxContainer/User+notifications/Profile/VBoxContainer/Rank/RankImage"

# Called when the node enters the scene tree for the first time.
func _ready():
	userlabel.text = LoginInfo.username
	var userinfo = await ApiCvrHttp.GetUserById(LoginInfo.userid)
	var imagurl = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.imageUrl
	profileimage = await Cache.get_image(imagurl, Cache.ITEM_TYPES.USER)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

