extends Node

@export var GetUserAgent : String = ('User-Agent: CVRY/')

func _ready():
	#Generate final user agent
	if OS.is_debug_build():
		GetUserAgent += 'development/'
	else:
		GetUserAgent += 'production/'
	
	GetUserAgent += (ProjectSettings.get_setting('application/config/version') + ' (')
	
	match OS.get_name():
		'Windows':
			GetUserAgent += 'Windows' + OS.get_version()
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			GetUserAgent += OS.get_distribution_name()
		'Android':
			GetUserAgent += 'Android' + OS.get_version()
		'iOS':
			GetUserAgent += 'iOS' + OS.get_version()
		'Web':
			GetUserAgent += 'WebDeploy'
	
	GetUserAgent += (' ' + Engine.get_architecture_name() + ')')
	print_debug(GetUserAgent)
	
