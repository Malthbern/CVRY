extends Node

const WorldCat : Dictionary = {
	Active =  'wrldactive',
	New = 'wrldnew',
	Trending = 'wrldtrending',
	Official = 'wrldofficial',
	Avatar = 'wrldavatars',
	Public = 'wrldpublic',
	RecentlyUpdated = 'wrldrecentlyupdated',
	Mine = 'wrldmine',
}


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

#active worlds
@onready var activecontainer = $"HBoxContainer/Active Worlds/Active Pannel/ScrollContainer/VBoxContainer"
var instancepane = load("res://Frontend/Desktop/SubScenes/instance_pane.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var request = ApiCvrHttp.GetUserById(LoginInfo.userid)
	var userinfo = await request.request_completed
	
	
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
	
	populate_active()

func populate_active():
	var reqworlds : HTTPRequest = ApiCvrHttp.GetWorldsByCategory(WorldCat.Active)
	var activeworlds = await reqworlds.request_completed
	reqworlds.queue_free()
	
	for world in JSON.parse_string(activeworlds[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.entries:
		var pane = instancepane.instantiate()
		activecontainer.add_child(pane)
		pane.playercount = world.playerCount
		pane.wid = world.id
		pane.Name = world.name
		pane.imgurl = world.imageUrl
		pane.applyworld()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

