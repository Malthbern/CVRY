extends Node

var currentusername:String
var currentaccesskey:String

var socket:WebSocketPeer
var previouscosket:WebSocketPeer

var reconnectattempts:int

var wsheaders:PackedStringArray = ['MatureContentDlc: true',
	'Platform: pc_standalone',
	'CompatibleVersions: 0,1,2',
]

const websocketaddress = 'wss://api.abinteractive.net/1/users/ws'
const maxreconnectattempt:int = 5

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

func _process(delta):
	if socket != null:
		socket.poll()
	else:
		return
	
	if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if reconnectattempts < maxreconnectattempt:
			reconnectattempts += 1
			ConnectWebsocket()
	
	if reconnectattempts < 0:
		var i = 0
		if i >= 60:
			i = 0
			reconnectattempts -= 1
		i += delta
	
	while socket.get_available_packet_count():
		process_packet(socket.get_packet())

func process_packet(Packet):
	var utf8 = Packet.get_string_from_utf8()
	var pktjson = JSON.parse_string(utf8)
	var restype = pktjson.ResponseType
	
	
	#I wanted to do a match operation but it didnt work
	#Most of these don't even need to be here as they wont get used
	#they are here for logging purposes mainly
	if restype == RESPONSE_TYPE.MENU_POPUP:
		pass
	
	if restype == RESPONSE_TYPE.HUD_MESSAGE:
		print_debug("Message: %s" %[pktjson.Message]) 
	
	if restype == RESPONSE_TYPE.ONLINE_FRIENDS:
		Cache.update_online_friends(pktjson.Data)
	
	if restype == RESPONSE_TYPE.INVITES:
		pass
	
	if restype == RESPONSE_TYPE.REQUEST_INVITES:
		pass
	
	if restype == RESPONSE_TYPE.FRIEND_REQUESTS:
		get_tree().root.propagate_call("friend_request", pktjson.Data)
