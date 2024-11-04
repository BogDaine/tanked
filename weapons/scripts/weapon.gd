class_name Weapon
extends Node

var projectile_basic_scn = WeaponUtils.projectile_basic_scn
var explosion_basic_scn = WeaponUtils.explosion_basic_scn

var _pos:Vector2
var _dir:Vector2
var _collision:CollisionMap

var _player:MultiplayerPlayer

var free_self = true

var _projectiles = []
var _explosions = []
var _weapons = []

signal explode(x:float, y:float, radius:float, destroy:bool)
signal damage(player1:MultiplayerPlayer, player2:MultiplayerPlayer, weapon:Weapon, pts:int)
signal done(weapon:Weapon)

func init(dir:Vector2, pos:Vector2, c:CollisionMap, player:MultiplayerPlayer) -> void:
	_pos = pos
	_dir = dir
	_collision = c
	_player = player

func check_done() ->bool:
	for p in _projectiles:
		if is_instance_valid(p):
			return false
	for e in _explosions:
		if is_instance_valid(e):
			return false
	for w in _weapons:
		if is_instance_valid(w):
			return false
	return true

func _relay_damage(player1:MultiplayerPlayer, player2:MultiplayerPlayer, weapon:Weapon, pts:int):
	damage.emit(player1, player2, weapon, pts)

func _relay_explode(x:float, y:float, radius:float, destroy:bool):
	explode.emit(x, y, radius, destroy)

func _explosion_basic(x:float, y:float, radius:float = 20, damage:bool = false, pts:int = 0, sound_func:Callable = Sounds.explosion, ignore_player:MultiplayerPlayer = null, timeout:float = 0.1):
	
	var e:Explosion = explosion_basic_scn.instantiate()
	e.position = Vector2(x,y)
	e.set_timeout(timeout)
	_explosions.append(e)
	add_child(e, true)
	e.radius = radius
	
	if is_instance_valid(ignore_player): 
		e.add_ignore_player(ignore_player)
	
	if damage:
		e.player_hit.connect(func(p,exp):do_damage(p, pts))
	
	explode.emit(x, y, radius, true)
	
	#Sounds.explosion()
	sound_func.call()
	GameGlobalsAutoload.screen_shaker.shake()

func do_damage(p_to:MultiplayerPlayer, pts:int):
	damage.emit(_player, p_to, self, pts)

func on_explosion_player_hit_basic(p:MultiplayerPlayer, e:Explosion):
	damage.emit(_player, p, self, 25)

func map_projectile_to_default_sounds(p:Projectile, bounces:bool = false):
	p.collision_bounds_exited.connect(func(p): Sounds.out_of_bounds())
	if bounces:
		p.bounce_sound.connect(func(p): Sounds.bounce())

func _physics_process(_delta: float) -> void:
	
	if check_done():
		done.emit(self)
		if free_self: queue_free()
			#print(name + " freed")
	#TODO: maybe don't self free, but let the parent free it
