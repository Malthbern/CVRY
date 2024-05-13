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

# Called when the node enters the scene tree for the first time.
func _ready():
	var userinfo = await ApiCvrHttp.GetUserById(LoginInfo.userid)
	# Profile
	userlabel.text = LoginInfo.username
	profileimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.imageUrl, Cache.ITEM_TYPES.USER)
	# Badge
	badgelabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.featuredBadge.name
	badgeimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.featuredBadge.image, Cache.ITEM_TYPES.BADGE)
	# Rank
	ranklabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.rank
	# Avatar
	avatarlabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.name
	avatarimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.imageUrl, Cache.ITEM_TYPES.AVATAR, JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

