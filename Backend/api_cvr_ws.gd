extends Node

var currentusername:String
var currentaccesskey:String

var pingpongtime:float = 15

var socket:WebSocketPeer
var previouscosket:WebSocketPeer

var wsheaders:PackedStringArray = ['MatureContentDlc: true',
	'Platform: pc_standalone',
	'CompatibleVersions: 0,1,2',
]

const websocketaddress = 'wss://api.abinteractive.net/1/users/ws'
const maxreconnectattempt = 5

# Websocket type constants
const RESPONSE_TYPE:Dictionary = {
	MENU_POPUP = 0,
	HUD_MESSAGE = 1,
	ONLINE_FRIENDS = 10,
	INVITES = 15,
	REQUEST_INVITES = 20,
	FRIEND_REQUESTS = 25
}

const MAP_INSTANCE:Dictionary = {
	'Id' = 'id',
	'Name' = 'name',
	'Privacy' = 'privacy',
}

const MAP_FRIEND:Dictionary = {
	'Id' = 'id',
	'IsOnline' = 'isOnline',
	'IsConnected' = 'isConnected',
	'Instance' = {
		root = 'instance',
		mapping = MAP_INSTANCE,
	},
}

const MAP_USER:Dictionary = {
	'Id' = 'id',
	'Name' = 'name',
	'ImageUrl' = 'imageUrl'
}

const MAP_WORLD:Dictionary = {
	'Id' = 'id',
	'Name' = 'name',
	'ImageUrl' = 'imageUrl',
}

const MAP_INVITE:Dictionary = {
	'Id' = 'id',
	'User' = {
		root = 'user',
		mapping = MAP_USER,
	},
	'World' = {
		root = 'world',
		mapping = MAP_WORLD,
	},
	'InstanceId' = 'instanceId',
	'InstanceName' = 'instanceName',
	'ReceiverId' = 'receiverId',
}

const MAP_REQUEST_INVITE:Dictionary = {
	'Id' = 'id',
	'Sender' = {
		root = 'sender',
		mapping = MAP_USER,
	},
	'ReceiverId' = 'receiverId',
}

func ConnectWithCredentials(username:String, accesskey:String):
	if (username != currentusername || accesskey != currentaccesskey) && previouscosket:
		await DisconnectWebsocket

func DisconnectWebsocket():
	pass

func PrepWS():
	#prep websocket and handshake headers
	socket = WebSocketPeer.new()
	var headerappend = [
		'Username: %s' % [LoginInfo.username],
		'AccessKey: %s' % [LoginInfo.logintoken],
	]
	wsheaders.append_array(headerappend)
	wsheaders.append(Utils.GetUserAgent)
	socket.handshake_headers = wsheaders
	
	ConnectWebsocket()

var socketid = 0
func ConnectWebsocket():
	if previouscosket != null:
		if  previouscosket.get_ready_state() == WebSocketPeer.STATE_OPEN || previouscosket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
			printerr('%s ' % [socketid] + 'previous socket is still conneted/connecting (%s)' % [previouscosket.get_ready_state()])
		if previouscosket.get_ready_state() == WebSocketPeer.STATE_CLOSING || previouscosket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			push_warning('%s ' % [socketid] + 'There was a previous socket but it is closed/closing (%s)' % [previouscosket.get_ready_state()])
	
	socketid = randi()
	socket.connect_to_url(websocketaddress)
	print_debug('websocket connecting to ' + websocketaddress + ' as ' + LoginInfo.username)
	previouscosket = socket

var pollinterval = 0
func _process(delta):
	pollinterval += delta
	if socket != null:
		if socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING:
			socket.poll()
		
		if pollinterval > pingpongtime:
			socket.poll()
			print_debug('Socket %s polled with state (%s)' % [socketid, socket.get_ready_state()])
			while socket.get_available_packet_count():
				print_debug(JSON.stringify(JSON.parse_string(socket.get_packet().get_string_from_utf8()), '\t',false,true))
			pollinterval = 0
		
	
