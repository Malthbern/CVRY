extends Panel

@onready var ThemeOptions = $ScrollContainer/VBoxContainer/Theme/OptionButton
@onready var HomeOption =$ScrollContainer/VBoxContainer/HomeTab/OptionButton

# Called when the node enters the scene tree for the first time.
func _ready():
	ThemeOptions.clear()
	for t:String in UserSettings.ThemesAvaliable:
		var shash:int =  t.hash()
		
		#This shouldn't need to happen but Popup.Item.ID is a 32-bit int
		#and godot only really uses 64-bit Ints everywhere else and dosen't overflow to Int32_min
		#also while Popup.Item.ID is a signed int32 it lifts anything < 0 back to 0
		while shash > 2147483647: #While greater than sint32_max
			var over = shash - 2147483647 #subtract INT32_Max from hash to be added back in next step
			shash = 0 + over #add back the remainder to the INT32_Min
		
		ThemeOptions.add_item(t.trim_suffix(".tres"), shash)
	
	var selectedtheme = ThemeOptions.get_item_index(UserSettings.savedsettings.theme)
	ThemeOptions.select(selectedtheme)
	UserSettings.load_theme(selectedtheme)
	
	HomeOption.select(UserSettings.savedsettings.hometab)


func UpdateTab():
	pass

func UpdateSettings():
	UserSettings.savesettings()

func _on_systemtray_toggled(toggled_on):
	UserSettings.savedsettings.closetotray = toggled_on
	UpdateSettings()

func _on_updatenotif_toggled(toggled_on):
	UserSettings.savedsettings.updatenotif = toggled_on
	UpdateSettings()

func _on_theme_item_selected(index: int) -> void:
	var id = ThemeOptions.get_item_id(index)
	UserSettings.savedsettings.theme = id
	UserSettings.load_theme(index)
	UpdateSettings()

func _on_home_tab_item_selected(index: int) -> void:
	UserSettings.savedsettings.hometab = index
	UpdateSettings()
