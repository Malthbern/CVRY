extends Control

var settings = UserSettings.usersettingstemplate

# Called when the node enters the scene tree for the first time.
func _ready():
	settings = UserSettings.savedsettings
	pass

func UpdateTab():
	pass

func _on_save_pressed():
	UserSettings.updatesettings(settings)


func _on_htime_toggled(toggled_on):
	settings.eurotime = toggled_on


func _on_systemtray_toggled(toggled_on):
	settings.closetotray = toggled_on


func _on_updatenotif_toggled(toggled_on):
	settings.updatenotif = toggled_on
