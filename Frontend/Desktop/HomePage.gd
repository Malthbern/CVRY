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

var timer:float
var refreashlimit:float = 60 #1 minuite cooldown for forced refreash
var autorefreash:float = 600 #10 minuite auto refreash timer

#user
@onready var userlabel = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/Username"
@onready var profileimage = $"HBoxContainer/User+notifications/Profile/HBoxContainer/PlayerProfPic"

#avatar
@onready var avatarlabel = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/CurrentAvatar/AvatarName"
@onready var avatarimage = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/CurrentAvatar/AvatarImage"

#badge
@onready var badgelabel = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/Badge/badgeName"
@onready var badgeimage = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/Badge/badgeImage"

#rank
@onready var ranklabel = $"HBoxContainer/User+notifications/Profile/HBoxContainer/VBoxContainer/Rank/RankName"

#active worlds
@onready var activecontainer = $"HBoxContainer/Active Worlds/Active Pannel/ScrollContainer/VBoxContainer"
var instancepane = load("res://Frontend/Desktop/SubScenes/instance_pane.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#seperated so that we can refreash these at any time
	populate_userdata()
	populate_active()

func refreash():
	depopulate_active()
	populate_userdata()
	populate_active()

func populate_userdata():
	var request = ApiCvrHttp.GetUserById(LoginInfo.userid)
	var userinfo = await request.request_completed
	request.queue_free()
	
	
	# Profile
	userlabel.text = LoginInfo.username
	profileimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.imageUrl, Cache.ITEM_TYPES.USER, LoginInfo.userid)
	# Badge
	badgelabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.featuredBadge.name
	badgeimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.featuredBadge.image, Cache.ITEM_TYPES.BADGE)
	# Rank
	ranklabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.rank
	# Avatar
	avatarlabel.text = JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.name
	avatarimage.texture = await Cache.get_image(JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.imageUrl, Cache.ITEM_TYPES.AVATAR, JSON.parse_string(userinfo[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()).data.avatar.id)

func depopulate_active():
	for child in activecontainer.get_children():
		child.queue_free()
	return

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
	

func UpdateTab():
	if timer >= refreashlimit:
		timer = 0
		await depopulate_active()
		populate_active()

func _process(delta):
	if timer < autorefreash:
		timer += delta
	else:
		UpdateTab()
