extends Panel

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
	
	var rand = randi_range(0,100)
	
	if rand < 10:
		var desktop = $"../../.."
		var csans:Font = load("res://Frontend/Comic.TTF")
		printerr("Oops! fogot to impliment the easteregg")
		# todo: add csans easteregg (blame DDAkebono)
	
	populate_userdata()
	populate_active()
	Cache.get_our_user_info()

func refreash():
	depopulate_active()
	populate_userdata()
	populate_active()

func populate_userdata():
	var userinfo = await ApiCvrHttp.GetUserById(LoginInfo.userid)
	
	# Profile
	userlabel.text = LoginInfo.username
	profileimage.texture = await Cache.get_image(userinfo.data.imageUrl, Cache.ITEM_TYPES.USER, LoginInfo.userid)
	# Badge
	badgelabel.text = userinfo.data.featuredBadge.name
	badgeimage.texture = await Cache.get_image(userinfo.data.featuredBadge.image, Cache.ITEM_TYPES.BADGE)
	# Rank
	ranklabel.text = userinfo.data.rank
	# Avatar
	avatarlabel.text = userinfo.data.avatar.name
	avatarimage.texture = await Cache.get_image(userinfo.data.avatar.imageUrl, Cache.ITEM_TYPES.AVATAR, userinfo.data.avatar.id)

func depopulate_active():
	for child in activecontainer.get_children():
		child.queue_free()
	return

func populate_active():
	var activeworlds = await ApiCvrHttp.GetWorldsByCategory(ApiCvrHttp.WorldCat.Active)
	
	for world in activeworlds.data.entries:
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
