extends Panel

@onready var VCon = $ScrollContainer/VBoxContainer
var friendrequest = load("res://Frontend/Desktop/SubScenes/friend_request_box.tscn")

func _ready():
	#populate with old friend requests at start
	var FriendRequests = await ApiCvrHttp.GetMyFriendRequests()
	pass

func notify(Message:JSON):
	pass
