class_name Breaker
extends Weapon

@export var projectile = preload("res://weapons/projectiles/projectile.tscn")
@export var explosion_scene = preload("res://weapons/explosions/explosion.tscn")
	
func _ready() -> void:
	_projectiles.append(projectile_basic_scn.instantiate())
	var p:Projectile = _projectiles.front()
	p.init(_dir, _pos, _collision)
	
	p.ground_hit.connect(func f(p): split(p))
	#p.bounce.connect(split)
	map_projectile_to_default_sounds(p)
	add_child(p, true)
	p.animated_sprite.play("breaker")

var exp_cnt = 0
func print_explosion_count():
	print("explosion count: " + str(exp_cnt))

var split_limit = 0
var split_cnt = 0
func split(p:Projectile):
	p.queue_free()
	split_cnt+=1
	#print("split <" + str(split_cnt) + ">")
	var p_new1:Projectile = projectile.instantiate()
	var p_new2:Projectile = projectile.instantiate()
	map_projectile_to_default_sounds(p_new1)
	map_projectile_to_default_sounds(p_new2)
	_projectiles.append(p_new1)
	_projectiles.append(p_new2)
	p_new1.init(Vector2(-1, -2).normalized() * 5,Vector2(p.position.x, p.position.y - 5), _collision)
	p_new2.init(Vector2(+1, -2).normalized() * 5,Vector2(p.position.x, p.position.y - 5), _collision)
	
	if(split_limit - split_cnt > 0):
		split_limit -= 1
		#p_new1.bounce.connect(split)
		#p_new2.bounce.connect(split)
		p_new1.ground_hit.connect(func f(c):split(c))
		p_new2.ground_hit.connect(func f(c):split(c))
	else:
		p_new1.ground_hit.connect(on_ground_hit)
		p_new2.ground_hit.connect(on_ground_hit)
		p_new1.player_hit.connect(on_player_hit)
		p_new2.player_hit.connect(on_player_hit)
	
	add_child(p_new1, true)
	add_child(p_new2, true)
	p_new1.animated_sprite.play("projectile")
	p_new2.animated_sprite.play("projectile")
	Sounds.split()

func on_ground_hit(p:Projectile):
	p.queue_free()
	_explosion_basic(p.position.x, p.position.y, 20, true, 20)

func on_player_hit(pl:MultiplayerPlayer, p:Projectile):
	if(p.distance_travelled < 0.1):
		return
	
	_explosion_basic(p.position.x, p.position.y, 20, true, 20)
	explode.emit(p.position.x, p.position.y + 10, 20, true)
	p.queue_free()
