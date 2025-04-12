extends Panel

var friendpannel = load("res://Frontend/Desktop/SubScenes/ObjectPresenter.tscn")
@export var containers:Array[Node]

var timer:float = 43190
var refreashtimer:float = 1800 #30 minuite manual refreash limit
var autorefreash:float = 43200 #12 hour auto refreash

var friends

@onready var allfriends = $"ScrollContainer/Friend Container"

func populatefriends():
	print_debug('Populating friends list')
	friends = await ApiCvrHttp.GetMyFriends()
	print_debug('Recieved %s friends' % [friends.data.size()])
	for friend in friends.data:
		var panel = friendpannel.instantiate()
		panel.ObjectName = friend.name
		panel.ObjectType = Cache.ITEM_TYPES.USER
		panel.UUID = friend.id
		panel.ImgUrl = friend.imageUrl
		panel.name = friend.name + friend.id
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
