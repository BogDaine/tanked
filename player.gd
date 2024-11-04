class_name Player
extends Node2D
@onready var collision_map:CollisionMap = $"../Map/Collision"
@onready var _area2D:Area2D = $Area2D

var team = 0
var points:int = 0

var disabled:bool = false

var _speed:float = 1
var _max_slope:float = 10
var _turret_pos:Vector2 = Vector2(0, -16)
var _turret_length:float = 24
var _shoot_strength:float = 13

var _mouse_pos:= Vector2.ZERO
#var _velocity:= Vector2.ZERO
var _velocity:= Vector2(-3, -4)
var _gravity = Vector2(0, 0.1)

signal was_hit(player:Player, pts:int)

func _ready() -> void:
	#_area2D.monitoring = true
	#_area2D.area_entered.connect(_on_entered)
	pass
	
func gethit(pts:int):
	was_hit.emit(self, pts)
	
func add_points(p:int):
	points += p
	print(self, "has ", points, "points!")
	#TODO: maybe not go below 0 points

func _on_entered(area: Area2D):
	pass

signal shoot(position:Vector2, direction:Vector2, strength:float, player:Player)

func rotate_to_ground():
	var normal = collision_map.collision_normal(position)
	rotation = normal.angle() + PI/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()

func input_move():
	
	var move_dir:int = 0
	if(Input.is_action_pressed("move_left")):
		move_dir = -1
	if(Input.is_action_pressed("move_right")):
		move_dir = + 1
	
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
		
var dir:Vector2 = Vector2(0,0)
func input_shoot():
	if Input.is_action_just_pressed("left_click"):
		shoot.emit(position + _turret_pos + dir * _turret_length,
							dir,
							_shoot_strength,
							self)
	
#DEBUG ONLY

#DEBUG ONLY		
func _draw():
	var line_point = (_mouse_pos - (position + _turret_pos)).normalized() * _turret_length#.rotated(rotation)
	draw_line(_turret_pos + dir, _turret_pos + dir * _turret_length, Color.BLUE, 2.0)

func do_steps():
	var velocity = _velocity
	
	
	for i in range (2):
		while(abs(velocity[i])>0):
			var normal = collision_map.collision_normal(position)
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
	

func _physics_process(_delta: float) -> void:
	
	_velocity+=_gravity
	do_steps()
	
	if(Input.is_action_just_pressed("ui_accept")):
		_velocity.y = -7
		_velocity.x = 3
