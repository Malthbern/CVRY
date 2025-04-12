extends Node

@onready var searchtermbox:TextEdit = $"."

func _on_button_pressed() -> void:
	print_debug(JSON.stringify(await ApiCvrHttp.Search(searchtermbox.text),"\t",false,true))
