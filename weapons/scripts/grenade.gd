extends Weapon


@export var projectile = preload("res://weapons/projectiles/projectile.tscn")
@export var explosion_scene = preload("res://weapons/explosions/explosion.tscn")
	
func _ready() -> void:
	var p:Projectile = projectile_basic_scn.instantiate()
	_projectiles.append(p)
	p.init(_dir, _pos, _collision)
	map_projectile_to_default_sounds(p, true)
	p.set_timeout(6.0)
	p.timeout.connect(on_projectile_timeout)
	add_child(p, true)
	p.animated_sprite.play("grenade")
	

#TODO:
#change player to multiplayerplayer
func explosion(x:float, y:float, p:Projectile, ignore_player:MultiplayerPlayer = null):
	p.queue_free()
	var e:Explosion = explosion_scene.instantiate()
	e.position = Vector2(x,y)
	e.set_timeout(0.5)
	_explosions.append(e)
	add_child(e, true)
	e.radius = 25
	e.player_hit.connect(on_explosion_player_hit)
	explode.emit(x, y, 25, true)
	
	Sounds.explosion()
	GameGlobalsAutoload.screen_shaker.shake()

func on_explosion_player_hit(p:MultiplayerPlayer, e:Explosion):
	damage.emit(_player, p, self, 50)

func on_projectile_timeout(p:Projectile):
	explosion(p.position.x, p.position.y, p)
	p.queue_free()
