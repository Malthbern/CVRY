extends Node

var friendpannel = load("res://Frontend/Desktop/SubScenes/Friend.tscn")
@export var containers:Array[Node]

var timer:float = 43190
var refreashtimer:float = 1800 #30 minuite manual refreash limit
var autorefreash:float = 43200 #12 hour auto refreash

var friends

@onready var allfriends = $"TabContainer/All/ScrollContainer/Friend Container"
@onready var fav = $"TabContainer/Favorites/ScrollContainer/Friend Container"

func populatefriends():
	print_debug('Populating friends list')
	friends = await ApiCvrHttp.GetMyFriends()
	print_debug('Recieved %s friends' % [friends.data.size()])
	for friend in friends.data:
		var panel = friendpannel.instantiate()
		panel.Username = friend.name
		panel.UUID = friend.id
		panel.ImgUrl = friend.imageUrl
		panel.name = friend.name + friend.id
		for cat in friend.categories:
			if cat == ('friend_%s' % [LoginInfo.userid]):
				fav.add_child(panel)
		allfriends.add_child(panel)

func depopulatefriends():
	pass

func UpdateTab():
	if timer > refreashtimer:
		timer = 0
		await depopulatefriends()
		populatefriends()

func _process(delta):
	if timer < autorefreash:
		timer += delta
	else:
		UpdateTab()
