extends Panel
@export var container : FlowContainer
@export_enum('Friends','Worlds','Avatars','Props') var tabType

var objectpannel = load("res://Frontend/Desktop/SubScenes/ObjectPresenter.tscn")

var FirstLoad:bool = true
var worlds

var timer:float = 0
var refreashtimer:float = 1800 #30 minuite manual refreash limit
var autorefreash:float = 43200 #12 hour auto refreash

func UpdateTab() -> void:
	var request
	var type
	
	if timer < refreashtimer && !FirstLoad:
		return
	
	FirstLoad = false
	
	match tabType:
		0:
			print_debug("Fetching my friends")
			request = await ApiCvrHttp.GetMyFriends()
			type = Cache.ITEM_TYPES.USER
			populatetab(request.data,type)
		
		1:
			print_debug("Fetching my worlds")
			request = await ApiCvrHttp.GetWorldsByCategory(ApiCvrHttp.WorldCat.Mine)
			type = Cache.ITEM_TYPES.WORLD
			populatetab(request.data.entries,type)
		
		2:
			print_debug("Fetching my avatars")
			request = await ApiCvrHttp.GetMyAvatars()
			type = Cache.ITEM_TYPES.AVATAR
			populatetab(request.data,type)
		
		3:
			print_debug("Fetching my props")
			request = await ApiCvrHttp.GetProps()
			type = Cache.ITEM_TYPES.PROP
			populatetab(request.data,type)

func populatetab(data:Array, type:String) -> void:
	for c in container.get_children():
		c.queue_free()
	
	for w in data:
		
		if type == Cache.ITEM_TYPES.AVATAR && !w.categories.has('avtrmine'):
			return
		
		if type == Cache.ITEM_TYPES.PROP && !w.categories.has('propmine'):
			return
		
		var panel = objectpannel.instantiate()
		panel.ObjectName = w.name
		panel.ObjectType = type
		panel.UUID = w.id
		panel.ImgUrl = w.imageUrl
		panel.name = w.name + w.id
		container.add_child(panel)

func _process(delta: float) -> void:
	if timer < autorefreash:
		timer += delta
	else:
		UpdateTab()
		timer = 0
