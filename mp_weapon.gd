class_name MpWeapon
extends Node

@export var _pos:Vector2
@export var _dir:Vector2
@export var _collision:CollisionMap
@export var _player:MultiplayerPlayer
@export var _player_id:int

#TODO
#nu poti trimite jucatori prin rpc. trebuie neaparat prin id, probabil..
@rpc("authority", "call_local", "reliable")
func init(pos:Vector2, dir:Vector2, p_id:int) -> void:
	_pos = pos
	_dir = dir
	_collision = GameGlobalsAutoload._map._collision
	_player_id = p_id
	
	var sb = SmolBoi.new()
	sb.init(_pos, _dir, _collision, _player_id)
	add_child(sb, true)
	
func _ready():
	
	pass
