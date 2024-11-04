extends Node
@onready var camera = $Camera2D
@onready var _map:Map = $Map

@onready var projectile = preload("res://projectile.tscn")
@onready var player_scn = preload("res://player.tscn")


@onready var _current_player:Player = $player


func _ready() -> void:
	var host_btn = $HostBtn
	var join_btn = $JoinBtn
	host_btn.pressed.connect(host)
	join_btn.pressed.connect(join)
	"if(is_instance_valid(camera)):
		camera.process_mode = Node.PROCESS_MODE_DISABLED
		camera.queue_free()
	"
	multiplayer.peer_connected.connect(on_peer_connected)

func on_peer_connected(id:int):
	print(id, " joined the game")

func host():
	var peer = WebSocketMultiplayerPeer.new()
	#see if it works without this
	peer.supported_protocols = ["ludus"]
	var error = peer.create_server(8085)
	
	if error:
		printerr(error)
	
	multiplayer.multiplayer_peer = peer
	
func join():
	var peer = WebSocketMultiplayerPeer.new()
	peer.supported_protocols = ["ludus"]
	var error:Error = peer.create_client("ws://" + "localhost" + ":" + str(8085))
	
	if error:
		printerr(error)
	multiplayer.multiplayer_peer = peer

func player_shoot(position:Vector2, direction:Vector2, strength:float, player:Player):
	
	var smol_boi = SmolBoi.new()
	smol_boi.explode.connect(_on_weapon_explode)
	smol_boi.damage.connect(_on_damage)
	smol_boi.init(direction * strength, position, _map._collision, player)
	add_child(smol_boi)
	
func _on_weapon_explode(x:float, y:float, radius:float, destroy:bool):
	if destroy:
		_map.explode(x, y, radius)

func _on_damage(player1:Player, player2:Player, weapon:Weapon, pts:int):
	print(player1, " hit ", player2, " for ", pts, " points!")

var zoom_ammount = 0.07
func camera_controls():
	if !is_instance_valid(camera):
		return
	var zoom_x:float = camera.zoom.x
	var zoom_y:float = camera.zoom.y
	
	if(Input.is_action_pressed("ui_up")):
		camera.position.y -= 3;
	if(Input.is_action_pressed("ui_down")):
		camera.position.y += 3;
	if(Input.is_action_pressed("ui_left")):
		camera.position.x -= 3;
	if(Input.is_action_pressed("ui_right")):
		camera.position.x += 3;
	if(Input.is_action_pressed("zoom_in")):
		zoom_x += zoom_ammount
		zoom_y += zoom_ammount
	if(Input.is_action_pressed("zoom_out")):
		zoom_x -= zoom_ammount
		zoom_y -= zoom_ammount
	
	camera.zoom = Vector2(clampf(zoom_x, 1, 3), clampf(zoom_y, 1, 3))

var mouse_pos:Vector2
func _draw():
	var player_pos = _current_player.position
	var camera_pos = camera.position
	#draw_circle(camera_pos - mouse_pos*(1/camera.zoom.x), 30, Color.DARK_OLIVE_GREEN)
	#^^very cool, dancing with the mouse :D^^
	#draw_circle(camera_pos + mouse_pos*(1/camera.zoom.x), 30, Color.DARK_OLIVE_GREEN, true, -1, true)

func _process(delta: float) -> void:
	camera_controls()
	mouse_pos = get_viewport().get_mouse_position()
	#print(mouse_pos)
	#var p = get_viewport().position
	#p = camera.position - get_viewport().get_mouse_position()
	#queue_redraw()

@rpc("any_peer", "call_local", "reliable")
func spawn_player(x:float):
	var p = player_scn.instantiate()
	p.position = Vector2(x, -1)
	add_child(p)

func player_controls():
	_current_player.input_move()
	
	if Input.is_key_pressed(KEY_P):
		spawn_player.rpc(randi_range(1, _map._width-2))
	
	var vp_mouse:Vector2 = camera.position + mouse_pos*(1/camera.zoom.x)
	var dir:Vector2 = (vp_mouse - (_current_player.position + _current_player._turret_pos)).normalized()
	_current_player.dir = dir
	if Input.is_action_just_pressed("left_click"):
		player_shoot(_current_player.position + _current_player._turret_pos+ dir * _current_player._turret_length,
						dir,
						_current_player._shoot_strength,
						_current_player)
	

func _physics_process(delta: float) -> void:
	player_controls()
	pass
