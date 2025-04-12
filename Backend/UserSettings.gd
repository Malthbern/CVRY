extends Node

const usersettingstemplate:Dictionary = {
	eurotime = true,
	closetotray = true,
	updatenotif = true,
	theme = "default",
	rememberme = true,
	hometab = 0,
}

@export var savedsettings:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	if !FileAccess.file_exists("user://CVRY/prefs.json"):
		print_debug("No settings file, using defaults.")
		savedsettings = usersettingstemplate.duplicate()
		return
	
	print_debug("Settings file found! loading prefrences")
	var prefsfile = FileAccess.open("user://CVRY/prefs.json", FileAccess.READ)
	
	if prefsfile == null:
		push_error("Preferences file could not be loaded!")
		return
	
	savedsettings = JSON.parse_string(prefsfile.get_as_text())
	print_debug("Preferences loaded")
	prefsfile.close
	

func updatesettings(settings:Dictionary = usersettingstemplate):
	var prefsfile = FileAccess.open("user://CVRY/prefs.json", FileAccess.WRITE_READ)
	
	if prefsfile == null:
		push_error("Could not open or create preference file")
		return
	
	var stringy = JSON.stringify(settings, "\t", false, true)
	prefsfile.store_string(stringy)
	print_debug("Settings saved!")
	prefsfile.close()
