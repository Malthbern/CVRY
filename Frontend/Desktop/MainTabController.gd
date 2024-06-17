extends TabContainer

@export var Tabs:Array[Node]

func _on_tab_changed(tab):
	Tabs[tab].UpdateTab()
