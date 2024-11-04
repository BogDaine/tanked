class_name SmolBoi
extends Weapon

@export var projectile = preload("res://weapons/projectiles/projectile.tscn")
@export var explosion_scene = preload("res://weapons/explosions/explosion.tscn")
@export var trail_scn = preload("res://scenes/trail.tscn")

func _ready() -> void:
	var p = projectile.instantiate()
	_projectiles.append(p)
	p.init(_dir, _pos, _collision)
	p.ground_hit.connect(explosion)
	p.player_hit.connect(player_hit)
	map_projectile_to_default_sounds(p)
	add_child(p, true)
	p.animated_sprite.play("projectile")
	
func on_projectile_bounce(p:Projectile):
	pass
func explosion(p:Projectile = null, ignore_player:MultiplayerPlayer = null):
	if p != null:
		p.queue_free()
	var e:Explosion = explosion_scene.instantiate()
	e.position = p.position
	e.set_timeout(0.1)
	_explosions.append(e)
	add_child(e, true)
	var radius = 20
	e.radius = radius
	if is_instance_valid(ignore_player): 
		e.add_ignore_player(ignore_player)
	
	e.player_hit.connect(on_explosion_player_hit)
	
	explode.emit(p.position.x, p.position.y, radius, true)
	
	Sounds.explosion()
	GameGlobalsAutoload.screen_shaker.shake()

func on_explosion_player_hit(p:MultiplayerPlayer, e:Explosion):
	damage.emit(_player, p, self, 25)
	
func player_hit(pl:MultiplayerPlayer, p:Projectile):
	p.ground_hit.disconnect(explosion)
	explosion(p) #use last parameter to ignore player
	explode.emit(p.position.x, p.position.y + 10, 20, true)
	p.queue_free()
												#for different damage on hit :D)
	
func explosion_entered():
	pass

func _process(delta: float) -> void:
	pass
