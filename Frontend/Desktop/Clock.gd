extends Label

var datetime
var time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	datetime = Time.get_datetime_dict_from_system()
	if datetime.minute < 10:
		time = '%s:0%s' % [datetime.hour, datetime.minute]
	else: 
		time = '%s:%s' % [datetime.hour, datetime.minute]
	text = time
