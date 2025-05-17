extends Panel

var objectpannel = load("res://Frontend/Desktop/SubScenes/ObjectPresenter.tscn")
var results

@onready var SearchInput = $VBoxContainer/Searchbar/SearchTerm

@onready var People = $"VBoxContainer/Search Types/People/ScrollContainer/FlowContainer"
@onready var Avatars = $"VBoxContainer/Search Types/Avatars/ScrollContainer/FlowContainer"
@onready var Props = $"VBoxContainer/Search Types/Props/ScrollContainer/FlowContainer"
@onready var Worlds = $"VBoxContainer/Search Types/Worlds/ScrollContainer/FlowContainer"

func UpdateTab():
	if People.get_children() != null:
		for child in People.get_children():
			child.queue_free()
	
	if Avatars.get_children() != null:
		for child in Avatars.get_children():
			child.queue_free()
	
	if Props.get_children() != null:
		for child in Props.get_children():
			child.queue_free()
	
	if Worlds.get_children() != null:
		for child in Worlds.get_children():
			child.queue_free()

func _on_search_pressed() -> void:
	results = await ApiCvrHttp.Search(SearchInput.text)
	UpdateTab()
	for object in results.data:
		var panel = objectpannel.instantiate()
		panel.ObjectName = object.name
		panel.UUID = object.id
		panel.ImgUrl = object.imageUrl
		panel.name = object.name + object.id
		
		if object.type == 'user':
			panel.ObjectType = Cache.ITEM_TYPES.USER
			People.add_child(panel)
		
		if object.type == 'avatar':
			panel.ObjectType = Cache.ITEM_TYPES.AVATAR
			Avatars.add_child(panel)
		
		if object.type == 'prop':
			panel.ObjectType = Cache.ITEM_TYPES.PROP
			Props.add_child(panel)
		
		if object.type == 'world':
			panel.ObjectType = Cache.ITEM_TYPES.WORLD
			Worlds.add_child(panel)
