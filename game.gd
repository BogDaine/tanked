extends Node

var map_scn = preload("res://Map.tscn")
var player_scn = preload("res://multiplayer_player.tscn")
var floating_label_scn = preload("res://FloatingLabel.tscn")
var score_ui_scn = preload("res://team_score_ui.tscn")


var take_turns:bool = true
var start_turn: int = 0
var infinite_weapons:bool = false
var infinite_fuel:bool = false
var max_fuel = 200
var turn_limit = 2

var turn:int = -1
var turn_count:int = 0
var all_teams_turns:int = 0
var team_count = 2

var game_active:bool = false

var _map:Map

var _player_dict = {}
var _team_scores = {}
var _weapons = {}


var _score_ui:TeamScoreUI
var _player_ui:PlayerUI
#TODO
#1. trebuie sa se puna jucatorii in pozitii in functie de echipa lor
#4. suneteee

func _ready() -> void:
	%mp_tests.show()
	GameGlobalsAutoload.screen_shaker = %ScreenShaker
	GameGlobalsAutoload.camera = %MainCamera

func _on_game_start():
	#gen_map()
	gen_map.rpc(randi())
	
	var width = _map._width
	
	var id0 = NetworkingAutoLoad._player_dict.keys()[0]
	add_player(id0, NetworkingAutoLoad.get_player_by_id(id0).name, 0, Vector2(width * 0.1, -2))
	
	if NetworkingAutoLoad._player_dict.keys().size() > 1:
		var id1 = NetworkingAutoLoad._player_dict.keys()[1]
		add_player(id1, NetworkingAutoLoad.get_player_by_id(id1).name, 1, Vector2(width * 0.9, -2))
		
	
	_team_scores[0] = 0
	_team_scores[1] = 0
	
	
	_score_ui = score_ui_scn.instantiate()
	%MpUI.add_child(_score_ui, true)
	
	turn_count = 0
	turn = start_turn
	
	if(take_turns):
		_score_ui.set_turn_limit.rpc(turn_limit)
		if turn == 1:
			set_team_players_disabled(true, 0)
			set_team_playermarkers_visible(false, 0)
			set_team_players_disabled(false, 1)
			set_team_playermarkers_visible(true, 1)		
		else:
			set_team_players_disabled(true, 1)
			set_team_playermarkers_visible(false, 1)
			set_team_players_disabled(false, 0)
			set_team_playermarkers_visible(true, 0)
	refuel_team(turn)
	
	update_player_settings()
	game_active = true
	
	_on_host_game_started.rpc()

func init_random_inventory():
	pass

@rpc("authority", "call_local", "reliable")
func _on_host_game_started():
	fetch_players()
	%LocalUI.move_child(%'PlayerUI', 1)
	%PlayerUI.show()
	%mp_tests.hide()
	multiplayer.get_unique_id()
	var id = multiplayer.get_unique_id()
	if _player_dict.has(id):
		%PlayerUI._player = _player_dict[id]
	
	%PlayerUI.infinite_weapons = infinite_weapons
	%PlayerUI.init()
	
	#set_only_playermarker_visible(id)

func update_player_settings():
	for key in _player_dict:
		if !(_player_dict[key] is MultiplayerPlayer):
			continue
		var p:MultiplayerPlayer = _player_dict[key]
		p.infinite_fuel = infinite_fuel
		p.max_fuel = max_fuel
		
func fetch_players():
	var players = %PlayersSpawn.get_children()
	for p in players:
		if p is MultiplayerPlayer:
			_player_dict[p.id] = p

func add_player(id:int, p_name:String, team:int, pos:Vector2):
	var p:MultiplayerPlayer = player_scn.instantiate()
	p.position = pos
	p.id = id
	p.team = team
	p.collision_map = GameGlobalsAutoload._map._collision
	p.shoot.connect(_on_player_shoot)
	p.p_name = p_name
	%PlayersSpawn.add_child(p, true)
	_player_dict[id] = p

func check_player_inventory(p:MultiplayerPlayer, index:int) -> bool:
	if infinite_weapons: return true
	if p.inventory[index] > 0:
		return true
	return false
func _on_player_shoot(pos:Vector2, shoot_dir:Vector2, shoot_strength:float, player:MultiplayerPlayer):
	var index = player.weapon_index
	if !check_player_inventory(player, index):
		print("<_on_player_shoot> not enough ammo!")
		return
		
	var shot:bool = false
	if take_turns:
		if player.team == turn:
			spawn_local_weapon.rpc(pos, shoot_dir, shoot_strength, player.id, index)
			player.disabled = true;
			shot = true
	else:
		spawn_local_weapon.rpc(pos, shoot_dir, shoot_strength, player.id, index)
		shot = true
	
	if shot:
		if !infinite_weapons:
			#player.inventory[index] -= 1
			player.set_ammo.rpc(index, player.inventory[index]-1)
		player.shoot_is_valid.rpc()

@rpc("authority", "call_local", "reliable")
func show_floating_message(message:String, pos:Vector2):
	var floating_message:FloatingLabel = floating_label_scn.instantiate()
	floating_message.text = message
	floating_message.position = pos
	%FloatingMessages.add_child(floating_message)

@rpc("authority", "call_local", "reliable")
func spawn_local_weapon(pos:Vector2, shoot_dir:Vector2, shoot_strength:float, player_id:int, idx:int):
	var p = _player_dict[player_id]
	var w:Weapon = GameGlobalsAutoload.weapon_descriptions[idx]["scene"].instantiate()
	w.explode.connect(_on_weapon_explode)
	w.damage.connect(_on_damage)
	w.done.connect(_on_weapon_done)
	#Only the server really needs to know who fired it
	var player
	if multiplayer.is_server():
		player = _player_dict[player_id]
	else: player = null
	
	Sounds.shoot()
	GameGlobalsAutoload.screen_shaker.shake(0.1, 0.002)
	w.init(shoot_dir.normalized() * shoot_strength, pos, GameGlobalsAutoload._map._collision, player)
	add_child(w)

func _on_weapon_explode(x:float, y:float, radius:float, destroy:bool):
	if destroy:
		GameGlobalsAutoload._map.explode(x, y, radius)

func _on_damage(player1:MultiplayerPlayer, player2:MultiplayerPlayer, _weapon:Weapon, pts:int):
	if player1 == null || player2 == null:
		return
		
	var actual_pts = pts
	if player1.team == player2.team:
		actual_pts *= -1
	#print(player1, " hit ", player2, " for ", actual_pts, " points!")
	_score_ui.add_points.rpc(actual_pts, player1.team)
	_team_scores[player1.team] += actual_pts
	show_floating_message.rpc(str(actual_pts), player2.position + Vector2.UP * 16)
	
func _on_weapon_done(w:Weapon):
	if !multiplayer.is_server(): return
	#print("weapon shot by: ", w._player.p_name)
	if take_turns:
		next_turn()

func set_only_playermarker_visible(id:int):
	for p in _player_dict:
		if _player_dict[p].id == id:
			_player_dict[p].set_playermarker_visible(true)
		else:
			_player_dict[p].set_playermarker_visible(false)
			

func set_team_playermarkers_visible(value:bool, team:int):
	if !multiplayer.is_server(): return
	for id in _player_dict:
		if _player_dict[id].team == team:
			_player_dict[id].set_playermarker_visible.rpc(value)

func refuel_team(team:int):
	if !multiplayer.is_server(): return
	for id in _player_dict:
		if _player_dict[id].team == team:
			_player_dict[id]._fuel = _player_dict[id].max_fuel
			
func set_team_players_disabled(value:bool, team:int):
	if !multiplayer.is_server(): return
	for id in _player_dict:
		if _player_dict[id].team == team:
			_player_dict[id].disabled = value

func next_turn():
	if turn == 0:
		turn = 1
		set_team_players_disabled(true, 0)
		set_team_playermarkers_visible(false, 0)
		set_team_players_disabled(false, 1)
		set_team_playermarkers_visible(true, 1)
		
		
	else:
		turn = 0
		set_team_players_disabled(true, 1)
		set_team_playermarkers_visible(false, 1)
		set_team_players_disabled(false, 0)
		set_team_playermarkers_visible(true, 0)
	
	refuel_team(turn)
	
	turn_count +=1
	
	#print("turn count: " + str(turn_count))
		
	all_teams_turns = turn_count/team_count
	_score_ui.set_turn.rpc(all_teams_turns)

func check_game_end() -> bool:
	if take_turns && turn_count/team_count >= turn_limit:
		return true
	
	return false

func host_game_end():
	game_active = false
	
	_score_ui.queue_free()
	on_game_terminated.rpc()
	

@rpc("authority", "call_local", "reliable")
func on_game_terminated():
	_map.queue_free()
	
	for k in _player_dict:
		_player_dict[k].queue_free()
	
	_player_dict.clear()
	%mp_tests.show()
	%PlayerUI.hide()
	%PlayerUI.reset()
	
var frames:int = 0
func _process(_delta: float) -> void:
	#var camera:Camera2D = GameGlobalsAutoload.camera;
	#camera.position.x += 1 * delta
	
	if !game_active: return
	frames += 1
	if frames == 10:
		frames = 0
		var peer = multiplayer.multiplayer_peer
		if peer == null:
			return
		if !multiplayer.is_server():
			return
		if check_game_end():
			print("Game over! Scores: " + str(_team_scores))
			host_game_end()

@rpc("authority", "reliable", "call_local")
func gen_map(seed:int = 0):
	_map = map_scn.instantiate()
	_map.seed = seed
	%MapSpawn.add_child(_map, true)
