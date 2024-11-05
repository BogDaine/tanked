class_name MultiplayerPlayer

extends Node2D

@onready var collision_map:CollisionMap
@onready var _area2D:Area2D = $Area2D
@export var id:int = 1


#TODO: maybe sync these too
@onready var name_label = $NameLabel
@export var p_name:String:
	set(value):
		p_name = value
		if is_instance_valid(name_label):
			name_label.text = value
			
@export var team = 0
@export var points:int = 0
@export var disabled:bool = false


var _max_slope:float = 10


@export var inventory = []

@export var _shoot_dir:= Vector2.ONE.normalized()
@export var _shoot_angle:float = PI/2
@export var _shoot_strength:float = 13:
	set(value):
		if disabled: return
		_shoot_strength = value

@export var weapon_index:int = 0
#server-side exports
@export var _max_shoot_strength:float = 40
@export var _turret_pos:Vector2 = Vector2(0, -8)
@export var _turret_length:float = 21
@export var _fuel:int = 255
@export var max_fuel:int = 255
@export var infinite_fuel = false
@export var _speed:float = 1


var _mouse_pos:= Vector2.ZERO
var _velocity:= Vector2(0, 0)
var _gravity = Vector2(0, 0.3)

var ignore_mouse:bool = false

signal shoot(position:Vector2, direction:Vector2, strength:float, player:MultiplayerPlayer)
signal shoot_valid(player:MultiplayerPlayer)
#unused
signal was_hit(player:Player, pts:int)

func _enter_tree() -> void:
	#name_label.text = p_name
	pass
func _ready() -> void:
	%MultiplayerInput.set_multiplayer_authority(id)
	name_label.text = p_name
	#_area2D.monitoring = true
	_area2D.area_entered.connect(_on_entered)
	
	for i in range(GameGlobalsAutoload.weapon_descriptions.size()):
		inventory.append(2)

@rpc("authority", "call_local", "reliable")
func set_ammo(index:int, ammo:int):
	if index < inventory.size():
		inventory[index] = ammo

@rpc("authority", "call_local", "reliable")
func shoot_is_valid():
	shoot_valid.emit(self)

func set_id(new_id:int):
	id = new_id

func gethit(pts:int):
	was_hit.emit(self, pts)
	
func add_points(p:int):
	points += p
	print(self, "has ", points, "points!")
	#TODO: maybe not go below 0 points

@rpc("authority", "reliable", "call_local")
func set_playermarker_visible(value:bool):
	if value:
		%PlayerMarker.show()
	else:
		%PlayerMarker.hide()

func _on_entered(area: Area2D):
	#print("<player> - " + area.get_parent().name)
	pass

func rotate_to_ground():
	var normal = collision_map.collision_normal(position, false)
	rotation = normal.angle() + PI/2

func _process(delta: float) -> void:
	queue_redraw()

func apply_input_move_test():
	position.x += %MultiplayerInput.input_dir
	
func apply_input_move():
	
	if !(infinite_fuel || _fuel > 0):
		return
	
	var move_dir = %MultiplayerInput.input_dir
	
	if move_dir == 0:
		return
		
	var new_pos:Vector2 = position + Vector2(move_dir, 0) * _speed
	
	if(new_pos.x < 0 or new_pos.x >= collision_map.width-1):
		return
		
	var move_ok: bool = true

	
	while new_pos.y > 0 and collision_map.pixels[new_pos.x][new_pos.y] == true and move_ok:
		if position.y - new_pos.y < _max_slope and new_pos.y > 1:
			new_pos.y = new_pos.y-1
		else:
			move_ok = false
	
	while new_pos.y+1 < collision_map.height and collision_map.pixels[new_pos.x][new_pos.y+1] == false and move_ok:
		if new_pos.y < collision_map.height - 1:# and new_pos.y > 0:
			new_pos.y = new_pos.y+1
			
	if move_ok:
		position = new_pos
		if !infinite_fuel:
			_fuel -= 1
		
func input_shoot():
	if Input.is_action_just_pressed("left_click"):
		shoot.emit(position + _turret_pos + _shoot_dir * 100,
							_shoot_dir,
							_shoot_strength,
							self)
@rpc("any_peer","call_local" ,"reliable")
func shoot_func():
	shoot.emit(position + _turret_pos + _shoot_dir * _turret_length,
								_shoot_dir,
								_shoot_strength,
								self)
func _on_shoot_signal():
	shoot_func.rpc_id(1)

#DEBUG ONLY

#DEBUG ONLY		
func _draw():
	#var line_point = (_mouse_pos - (position + _turret_pos)).normalized()
	# * _turret_length#.rotated(rotation)
	var line_point = (%MultiplayerInput._mouse_pos - (position + _turret_pos)).normalized() * _turret_length
	#draw_line(_turret_pos + dir, _turret_pos + dir * _turret_length, Color.BLUE, 2.0)
	#draw_line((_turret_pos), %MultiplayerInput._aim_pos - (position), Color.BLUE, 2.0)
	draw_line((_turret_pos), _turret_pos + _shoot_dir * _turret_length, Color.BLUE, 2.0)
func do_steps():
	var velocity = _velocity
	
	
	for i in range (2):
		while(abs(velocity[i])>0):
			var normal = collision_map.collision_normal(position, false)
			velocity[i] -= min(0.5,abs(velocity[i])) * sign(velocity[i])
			var normal_sign_x = sign(normal.x)
			var normal_sign_y = sign(normal.y)
			var normal_sign = Vector2(normal_sign_x, normal_sign_y)
		
			if(normal == Vector2.ONE):
				_velocity = Vector2.ZERO
				break
			
			for j in range(2):
				if normal.y < 0 and velocity.y > 0:
					velocity.x = 0
					velocity.y = 0
					_velocity.x = 0
					_velocity.y = 0
					break
				if normal_sign[j] != 0 and normal_sign[j] != sign(_velocity[j]):
					if(j == 1):
						velocity[j] = 0
						_velocity[j] = 0
					else:
						velocity[j] = -velocity[j] * 0.3
						_velocity[j] = -_velocity[j] * 0.3
			
			position[i] += min(.5,abs(velocity[i])) * sign(velocity[i])
	
var angle_speed = 1
var strength_speed = 15
func process_passive_inputs(delta:float):
	_shoot_angle += %MultiplayerInput.angle_change * delta * angle_speed
	_shoot_dir = Vector2(-1, 0).rotated(_shoot_angle)
	
	_shoot_strength += %MultiplayerInput.shoot_strength_change * delta * strength_speed
	_shoot_strength = clampf(_shoot_strength, 0, _max_shoot_strength)
	
	
func on_aim_pos_changed():
	if ignore_mouse || disabled: return
	
	var ap:Vector2 = %MultiplayerInput._aim_pos
	_shoot_angle = ap.angle_to_point(position + _turret_pos)
	_shoot_dir = Vector2(-1, 0).rotated(_shoot_angle)

	
func _physics_process(delta: float) -> void:
	
	#TODO
	if !disabled:
		process_passive_inputs(delta)
	
	
	if multiplayer.is_server():
		#apply_input_move_test()
		if !disabled:
			apply_input_move()
		_velocity+=_gravity
		do_steps()
	#if(Input.is_action_just_pressed("ui_accept")):
	#	_velocity.y = -7
	#	_velocity.x = 3
