class_name Projectile
extends Node2D
var collision_map:CollisionMap

#TODO: maybe separate animations from the physics script :)
@onready var animated_sprite:AnimatedSprite2D = %AnimatedSprite2D
@onready var timer = Timer.new()
@onready var area = $Area2D

var _dir:Vector2 = Vector2.ZERO
var free_on_exit_bounds:bool = true

var initial_pos:=Vector2.ZERO

var _gravity = Vector2(0, 0.4)

#var timeout_time:float = 0
var friction:float = 0.5
var slide_coef:float = 0.01

var distance_travelled:float = 0
	#set(value):
	#	pass
var distance_travelled_x:float = 0
	#set(value):
	#	pass
var distance_travelled_y:float = 0
	#set(value):
	#	pass
#TODO: this code is duplicate of the explosion code. Maybe inherit it from another class for both :)
@onready var _area:Area2D = $Area2D
var radius:float = 10:
	set(value):
		var c = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = radius
		set_shape(circle)
		radius = value

var _tick_cnt = 0:
	set(value):
		pass

signal ground_hit(p:Projectile)
signal in_ground(p:Projectile)
signal player_hit(player:MultiplayerPlayer, p:Projectile)
signal collision_bounds_exited(p:Projectile)
signal timeout(p:Projectile)
signal bounce(p:Projectile)
signal bounce_sound(p:Projectile) #bounce with minimum velocity so your ears dont bleed :)
signal bounce_limit_reached
signal velocity_zero
signal above_other_player
signal tick(p:Projectile)

func set_shape(shape:Shape2D):
	if !is_instance_valid(_area):
		printerr("area accessed too early perhaps")
		return
		
	for child in _area.get_children():
		_area.remove_child(child)
		
	var c:CollisionShape2D = CollisionShape2D.new()
	c.set_deferred("shape", shape)
	_area.add_child(c)


func _ready() -> void:
	area.area_entered.connect(on_area_entered)
	area.area_exited.connect(on_area_exited)

func set_tick(t:float):
	var timer:Timer = Timer.new()
	timer.timeout.connect(_on_tick)
	timer.wait_time = t
	timer.autostart = true
	add_child(timer)

func set_timeout(t:float):
	var timer:Timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.wait_time = t
	timer.autostart = true
	add_child(timer)

func init(d:Vector2, p:Vector2, c:CollisionMap):
	_dir = d
	position = p
	initial_pos = p
	collision_map = c

func on_area_entered(a: Area2D):
	var p = a.get_parent()
	if p is MultiplayerPlayer:
		player_hit.emit(p, self)

func on_area_exited(a: Area2D):
	var c = a.get_parent()
	if c == collision_map:
		collision_bounds_exited.emit(self)
		if free_on_exit_bounds:
			queue_free()

signal explode(x:float, y:float, radius:float, destroy:bool)

func explosion(x, y, radius:float, destroy:bool = true, free:bool = true):
	explode.emit(x, y, radius, destroy)
	if free:
		queue_free()
func explosionv(pos:Vector2, radius:float, destroy:bool = true, free:bool = true):
	explosion(pos.x, pos.y, radius, destroy, free)

func _on_timeout():
	timeout.emit(self)

func _on_tick():
	_tick_cnt += 0
	tick.emit(self)

var hit_ground:bool = false

func do_steps():
	var hit_ground_now:bool = false
	var velocity = _dir
	var bounced:bool = false
	
	for i in range (2):
		while(abs(velocity[i])>0):
			var normal = collision_map.collision_normal(position)
			var step = min(0.5,abs(velocity[i])) * sign(velocity[i])
			velocity[i] -= step
			distance_travelled += abs(step)
			
			if i == 0:
				distance_travelled_x += abs(step)
			if i == 1:
				distance_travelled_y += abs(step)
				
			var normal_sign_x = sign(normal.x)
			var normal_sign_y = sign(normal.y)
			var normal_sign = Vector2(normal_sign_x, normal_sign_y)
			
			if(normal == Vector2.ONE):
				if !hit_ground:
					ground_hit.emit(self)
					hit_ground = true
					hit_ground_now = true
					in_ground.emit(self)
				#print(normal)
				
				#if stop_process_on_ground_hit:
					#set_process(false)
				return
			
			for j in range(2):
				if normal_sign[j] != 0 and normal_sign[j] != sign(_dir[j]):
					if !hit_ground:
						ground_hit.emit(self)
						hit_ground = true
					velocity[j] = -velocity[j] * (1-friction)
					_dir[j] = -_dir[j] * (1-friction)
					
					
					if !bounced:
						if j == 0:
							_dir[1] = _dir[1] * (1-slide_coef)
							velocity[1] = velocity[1] * (1-slide_coef)
						else:
							_dir[0] = _dir[0] * (1-slide_coef)
							velocity[0] = velocity[0] * (1-slide_coef)
						
						bounce.emit(self)
						bounced = true
						
						if abs(_dir.length()) > 1 && abs(_dir[j]) > 1:
							bounce_sound.emit(self)
							break;#bounce_sound.emit(self)
						
			position[i] += min(0.5,abs(velocity[i])) * sign(velocity[i])
	

func _physics_process(_delta: float) -> void:
	do_steps()
	_dir += _gravity
	#gravity
