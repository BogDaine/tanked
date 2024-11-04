extends Node

var _player_dict = {}

var local_player_info = PlayerInfo.new()

var _peer = WebSocketMultiplayerPeer.new()

signal peer_added(id:int)
signal peer_removed(id:int)
signal peer_removed_name(id:int, name:String)
signal server_disconnected()
signal player_updated(id:int)

func _init():
	_peer.supported_protocols = ["ludus"]
	

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	
func _process(_delta: float) -> void:
	pass

func get_player_by_id(id:int) -> PlayerInfo:
	return _player_dict[id]

func become_host(port:int = 8087):
	var error = _peer.create_server(port)
	multiplayer.multiplayer_peer = _peer

func join_game(host:String, port:int = 8087):
	var error:Error = _peer.create_client("ws://" + host + ":" + str(port))
	
	multiplayer.multiplayer_peer = _peer

@rpc("authority")
func disconnect_multiplayer():
	multiplayer.multiplayer_peer.close()

func _on_server_disconnected():
	server_disconnected.emit()
	_player_dict.clear()

func _on_connected_to_server():
	pass

@rpc("any_peer", "reliable")
func update_name(p_name:String):
	var id = multiplayer.get_remote_sender_id()
	var new_player = PlayerInfo.new()
	new_player.id = id
	new_player.name = p_name
	new_player.team = 0
	_player_dict[id] = new_player
	player_updated.emit(id)
	
	#_player_dict[id] = p_name
	multiplayer.connection_failed

func add_playerinfo(id:int, p_name:String = "", team:int = 0):
	var new_player = PlayerInfo.new()
	new_player.id = id
	if p_name.length() == 0:
		new_player.name = str(id)
	else :
		new_player.name = p_name
	new_player.team = team
	_player_dict[id] = new_player

func _on_peer_connected(id:int):
	
	var new_player = PlayerInfo.new()
	new_player.id = id
	new_player.name = str(id)
	new_player.team = 0
	_player_dict[id] = new_player
	
	peer_added.emit(id)
	
	print(str(id)+" connected")

func _on_peer_disconnected(id):
	peer_removed.emit(id)
	peer_removed_name.emit(id, _player_dict[id])
	_player_dict.erase(id)
	print(str(id)+" disconnected")
	
