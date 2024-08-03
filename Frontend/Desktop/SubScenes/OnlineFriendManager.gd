extends Node

@onready var worldcontainer = $"Online Panel/ScrollContainer/VBoxContainer"
@onready var notconnected = $"Online Panel/ScrollContainer/VBoxContainer/OnlineNotConnected"
@onready var private = $"Online Panel/ScrollContainer/VBoxContainer/PrivateFriendPanel"

var panel = load("res://Frontend/Desktop/SubScenes/active_friend_panel.tscn")

func _ready():
	Cache.Online_Friends_Updated.connect(updateui)

func updateui():
	var children = worldcontainer.get_children()
	
	for friend in Cache.Online_Friends:
		var childpanel
		
		for child in children:
			child.removeuser(friend)
		
		if friend.Instance != null:
			childpanel = worldcontainer.find_child(friend.Instance.Id, false, false)
		
		if childpanel == null && friend.Instance != null:
			var user = await ApiCvrHttp.GetUserById(friend.Id)
			childpanel = await createworldpannel(friend.Instance.Id, friend.Instance.Name, friend.Instance.Privacy, user.data.instance.world.imageUrl, user.data.instance.world.id)
		
		if childpanel != null:
			childpanel.adduser(friend)
		
		if friend.Instance == null && friend.IsConnected:
			private.adduser(friend)
	

func createworldpannel(instanceid:String, WorldName:String, Privacy:int, imageurl:String, WorldId:String):
	var instance = panel.instantiate()
	instance.worldname = WorldName
	instance.name = instanceid
	instance.imagurl = imageurl
	instance.worldid = WorldId
	worldcontainer.add_child(instance, true)
	await instance.setworld()
	return instance
