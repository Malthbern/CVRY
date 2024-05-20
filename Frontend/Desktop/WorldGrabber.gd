extends Node

@export var ishomepage : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	if ishomepage:
		var reqworlds : HTTPRequest = ApiCvrHttp.GetWorldsByCategory(WorldCat.Active)
		var activeworlds = await reqworlds.request_completed
		reqworlds.queue_free()
		print_debug(JSON.stringify(JSON.parse_string(activeworlds[ApiCvrHttp.PACKED_RESPONSE.DATA].get_string_from_utf8()),'\t',false))
#	
