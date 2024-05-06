extends Node

@export var GetUserAgent : String = ('CVR-Y/' + ProjectSettings.get_setting('application/config/version') + '/deployment:')
var entity
var mapping
var object

var entityToMap

#@export var DeepClone = JSON.parse(JSON.stringify(obj))

func _ready():
	#Generate final user agent
	if Engine.is_editor_hint():
		GetUserAgent += 'development/'
	else:
		GetUserAgent += 'production/'
	
	match OS.get_name():
		'Windows':
			GetUserAgent += 'Windows' + OS.get_version() +'/'
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			GetUserAgent += OS.get_distribution_name() + '/'
		'Android':
			GetUserAgent += 'Android' + OS.get_version() + '/'
		'iOS':
			GetUserAgent += 'iOS' + OS.get_version() +'/'
		'Web':
			GetUserAgent += 'WebDeploy' +'/'
	
	GetUserAgent += Engine.get_architecture_name()
	print_debug('UserAgent: ' + GetUserAgent)
	
	for apikey in mapping:
		if object.prototype.hasOwnProperty.call(entityToMap, apikey):
			var ourkey = mapping[apikey]
