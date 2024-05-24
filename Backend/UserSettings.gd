extends Node

const usersettingstemplate:Dictionary = {
	eurotime = true,
	closetotray = true,
	updatenotif = true,
	theme = "default",
	rememberme = true,
	hometab = 0,
}

var savedsettings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updatesettings(settings:Dictionary = usersettingstemplate):
	pass
