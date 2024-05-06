extends Node

var Desktop = "res://Frontend/Desktop/Desktop.tscn"
var Mobile = "res://Frontend/Mobile/Mobile.tscn"
var Loading = "res://Frontend/Startup/Startup.tscn"
var Login = "res://Frontend/Login/Login.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	var l = load(Login).instantiate()
	get_tree().root.add_child(l)

func load_complete(Scene:Node):
	get_tree().root.remove_child(Scene)
	
