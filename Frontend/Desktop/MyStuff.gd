extends Panel
@export var container : FlowContainer
@export_enum('Friends','Worlds','Avatars','Props') var tabType

const WorldCategories = {
	'ActiveInstances': 'wrldactive',
	'New': 'wrldnew',
	'Trending': 'wrldtrending',
	'Official': 'wrldofficial',
	'Avatar': 'wrldavatars',
	'Public': 'wrldpublic',
	'RecentlyUpdated': 'wrldrecentlyupdated',
	'Mine': 'wrldmine',
}


var objectpannel = load("res://Frontend/Desktop/SubScenes/ObjectPresenter.tscn")

var FirstLoad:bool = false
var worlds

var timer:float = 43190
var refreashtimer:float = 1800 #30 minuite manual refreash limit
var autorefreash:float = 43200 #12 hour auto refreash

func UpdateTab() -> void:
	var request
	var type
	
	match tabType:
		0:
			print_debug("Fetching my friends")
			request = await ApiCvrHttp.GetMyFriends()
			type = Cache.ITEM_TYPES.USER
			populatetab(request.data,type)
		
		1:
			print_debug("Fetching my worlds")
			request = await ApiCvrHttp.GetWorldsByCategory(WorldCategories.Mine)
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
		var panel = objectpannel.instantiate()
		panel.ObjectName = w.name
		panel.ObjectType = type
		panel.UUID = w.id
		panel.ImgUrl = w.imageUrl
		panel.name = w.name + w.id
		container.add_child(panel)
