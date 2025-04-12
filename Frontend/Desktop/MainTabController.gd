extends TabContainer

@export var Tabs:Array[Node]

func _ready():
	Tabs[UserSettings.savedsettings.hometab].UpdateTab()
	current_tab = UserSettings.savedsettings.hometab

func _on_tab_changed(tab):
	Tabs[tab].UpdateTab()
