extends TextureRect

@export var SpeedMultiplier = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = rotation + (delta * SpeedMultiplier)
