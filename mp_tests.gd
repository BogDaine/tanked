extends Control
@onready var messages_label:Label = $Panel/HSplitContainer/VSplitContainer/Panel/ScrollContainer/Messages
@onready var player_name_edit:LineEdit = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/PlayerNameEdit
@onready var player_name_list:ItemList = $Panel/HSplitContainer/HBoxContainer/PlayerNameList

@onready var port_edit:LineEdit = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/PortEdit
@onready var host_edit:LineEdit = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/HostNameEdit
@onready var msg_edit:TextEdit = $Panel/HSplitContainer/VSplitContainer/Panel/HBoxContainer/MsgEdit

@onready var host_btn:Button = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/HostBtn
@onready var connect_btn:Button = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/ConnectBtn
@onready var disconnect_btn:Button = $Panel/HSplitContainer/VSplitContainer/HBoxContainer/DisconnectBtn
@onready var send_btn:Button = $Panel/HSplitContainer/VSplitContainer/Panel/HBoxContainer/SendBtn


var port_edit_regex:RegEx = RegEx.new()

#var peer = WebSocketMultiplayerPeer.new()
var _player_dict = {}

signal game_start()

func _init() -> void:
#	peer.supported_protocols = ["ludus"]
	pass
func _ready() -> void:
	
	host_btn.pressed.connect(on_host_btn_pressed)
	connect_btn.pressed.connect(on_connect_btn_pressed)
	disconnect_btn.pressed.connect(on_disconnect_btn_pressed)
	send_btn.pressed.connect(on_send_btn_pressed)
	
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	#multiplayer.connection_failed.connect()
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	#multiplayer.server_disconnected.connect()
	multiplayer.get_remote_sender_id()
	
	NetworkingAutoLoad.peer_added.connect(_on_player_added)
	NetworkingAutoLoad.peer_removed.connect(_on_player_removed)
	NetworkingAutoLoad.player_updated.connect(_on_player_updated)
	NetworkingAutoLoad.server_disconnected.connect(_on_server_disconnected)
	
	port_edit.text_changed.connect(on_portedit_text_changed)
	
	port_edit_regex.compile("^[0-9]*$")
	
	multiplayer.multiplayer_peer = null
	
	var peer = WebSocketMultiplayerPeer.new()
	peer.supported_protocols = ["ludus"]

@rpc("any_peer", "call_local", "reliable")
func push_message(m:String):
	messages_label.text += m+'\n'

func add_self():
	#TODO: teams...
	var team: = 0
	var id = multiplayer.get_unique_id()
	NetworkingAutoLoad.add_playerinfo(id, player_name_edit.text, team)
	_on_player_added(id)
	
func _on_player_added(id:int):
	_player_dict[id] = NetworkingAutoLoad.get_player_by_id(id)
	player_name_list.add_item(_player_dict[id].name)
func _on_server_disconnected():
	player_name_list.clear()
	_player_dict.clear()

func _on_player_removed(id:int):
	#if _player_dict.find_key(id) == null:
	#	return
		
	var p_name = _player_dict[id].name
	for i in range(player_name_list.item_count):
		if p_name == player_name_list.get_item_text(i):
			player_name_list.remove_item(i)
	_player_dict.erase(id)

func _on_player_updated(id):
	var new_val =  NetworkingAutoLoad.get_player_by_id(id)
	
	player_name_list.add_item(new_val.name)
	var item_index = player_name_list.item_count-1
	var p_name = _player_dict[id].name
	for i in range(player_name_list.item_count-1):
		if p_name == player_name_list.get_item_text(i):
			player_name_list.move_item(item_index, i)
			player_name_list.remove_item(i+1)
	_player_dict[id].name = new_val.name

func on_connected_to_server():
	add_self()
	var id = multiplayer.get_unique_id()
	var p_name = NetworkingAutoLoad.get_player_by_id(id).name
	push_message.rpc(p_name + " has joined the server")

func on_peer_connected(id:int):
	push_message(str(id) + " connected")
	var p_name = player_name_edit.text
	if p_name.length() > 0:
		NetworkingAutoLoad.update_name.rpc(p_name)

func on_peer_disconnected(id):
	push_message(str(id) + " has disconnected")
	
func on_send_btn_pressed():
	var p_name = NetworkingAutoLoad.get_player_by_id(multiplayer.get_unique_id()).name
	if(multiplayer.has_multiplayer_peer()):
		push_message.rpc(p_name + ": " + msg_edit.text)
		msg_edit.text = ""
		return
	push_message("you are unconnected, can't send message")
	
func on_host_btn_pressed():
	if port_edit.text.length() == 0:
		push_message("cannot host: port undefined...")
		return
	
	NetworkingAutoLoad.become_host(port_edit.text.to_int())
	push_message("server hosted on port " + port_edit.text)
	add_self()
	
func on_connect_btn_pressed():
	if port_edit.text.length() == 0:
		push_message("cannot join: port undefined...")
		return
	NetworkingAutoLoad.join_game(host_edit.text, port_edit.text.to_int())
	

func on_disconnect_btn_pressed():
	NetworkingAutoLoad.disconnect_multiplayer()
	#multiplayer.multiplayer_peer = null
	#peer.close()

func _on_settings_btn_pressed():
	pass

func _on_start_btn_pressed():
	if !multiplayer.is_server():
		push_message("only the host can start the game")
		return
		
	game_start.emit()


@onready var old_port_text = port_edit.text

func on_portedit_text_changed(new_text):
	if port_edit_regex.search(new_text):
		old_port_text = str(new_text)
	else:
		port_edit.text = old_port_text
		port_edit.set_caret_column(port_edit.text.length())
