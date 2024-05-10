extends TextureRect

@export var SpeedMultiplier = 5
@export var waittwarn : float = 10
var waited : float

@onready var timewarn = $"../TimeWarn"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = rotation + (delta * SpeedMultiplier)
	
	if waited > waittwarn:
		timewarn.visible = true
	else:
		waited += delta
