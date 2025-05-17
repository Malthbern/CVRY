extends Node

const usersettingstemplate:Dictionary = {
	closetotray = true,
	updatenotif = true,
	theme = 0,
	rememberme = true,
	hometab = 0,
}

@export var savedsettings:Dictionary

@export var ThemesAvaliable:Array

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
	
	get_themes()

func savesettings():
	var prefsfile = FileAccess.open("user://CVRY/prefs.json", FileAccess.WRITE_READ)
	
	if prefsfile == null:
		push_error("Could not open or create preference file")
		return
	
	var stringy = JSON.stringify(savedsettings, "\t", false, true)
	prefsfile.store_string(stringy)
	print_debug("Settings saved!")
	prefsfile.close()

func get_themes():
	ThemesAvaliable.clear()
	ThemesAvaliable.append("CVR OG Green.tres")
	
	var dir := DirAccess.open("user://CVRY/themes/")
	if dir == null: printerr("Could not open folder"); return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		ThemesAvaliable.append(file)

func load_theme(index:int) -> void:
	print_debug("setting theme to %s" %[ThemesAvaliable[index]])
	
	if index == 0:
		var customtheme = Theme.new()
		customtheme = await load(ThemesAvaliable[index])
		get_tree().root.theme = customtheme
		get_tree().root.propagate_call("update_theme")
		return
	
	var ThemeName = ("user://CVRY/themes/" + ThemesAvaliable[index])
	if FileAccess.file_exists(ThemeName):
		var customtheme = Theme.new()
		customtheme = await load(ThemeName)
		
		if customtheme == Theme.new():
			printerr("Failed to load theme from %s" %[ThemeName])
		
		get_tree().root.theme = customtheme
		get_tree().root.propagate_call("update_theme")
