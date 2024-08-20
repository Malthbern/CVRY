extends Button

@export var URL:String

func _ready():
	self.pressed.connect(openurl)
	

func openurl():
	if URL == null:
		push_error("Tried to open null url on %s" % [self.name])
		return
	
	OS.shell_open(URL)
