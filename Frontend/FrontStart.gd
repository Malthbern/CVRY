extends Node

var Desktop = "res://Frontend/Desktop/Desktop.tscn"
var Mobile = "res://Frontend/Mobile/Mobile.tscn"
var Loading = "res://Frontend/Startup/Startup.tscn"
var Login = "res://Frontend/Login/Login.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func load_complete(Scene:Node):
	var l = load(Login).instantiate()
	get_tree().root.add_child.call_deferred(l)
	get_tree().root.remove_child(Scene)
	

func loadUI(UIToLoad:String):
#	var FirstScene = get_tree().root.get_node("/root/Startup") 
#	
#	print_debug(FirstScene.name)
#	
#	if FirstScene != null:
#		get_tree().root.remove_child.call_deferred(FirstScene)
#		FirstScene.queue_free()
#	
	match UIToLoad:
# Assume if not a mobile device / Login when calling loadUI we want some desktop enviorment
		'Android','iOS':
			get_tree().change_scene_to_file.call_deferred(Mobile)
		'Login':
			get_tree().change_scene_to_file.call_deferred(Login)
		'Load':
			get_tree().change_scene_to_file.call_deferred(Loading)
		_:
			get_tree().change_scene_to_file.call_deferred(Desktop)
	

func unloadUI(UIUnload:Node):
	get_tree().root.remove_child(UIUnload)
	UIUnload.queue_free()
