extends Node

var Desktop = "res://Frontend/Desktop/Desktop.tscn"
var Mobile = "res://Frontend/Mobile/Mobile.tscn"
var Loading = "res://Frontend/Startup/Startup.tscn"
var Login = "res://Frontend/Login/Login.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ApiCvrHttp.Authenticate(1,'Malthbern','U8kBgAgVJuUWQ4Y')

func load_complete(Scene:Node):
	var l = load(Login).instantiate()
	get_tree().root.add_child.call_deferred(l)
	get_tree().root.remove_child(Scene)
	

func loadUI(UIToLoad:String):
	var FirstScene = get_tree().root.get_node("/root/Startup") 
	
	print_debug(FirstScene.name)
	
	if FirstScene != null:
		get_tree().root.remove_child.call_deferred(FirstScene)
		FirstScene.queue_free()
	
	match UIToLoad:
		'Desktop':
			get_tree().root.add_child.call_deferred(Desktop)
		'Mobile':
			get_tree().root.add_child.call_deferred(Mobile)
		'Login':
			get_tree().root.add_child.call_deferred(Login)
		
	

func unloadUI(UIUnload:Node):
	get_tree().root.remove_child(UIUnload)
	UIUnload.queue_free()
