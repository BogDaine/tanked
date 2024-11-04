extends Weapon

func _ready() -> void:
	var p:Projectile = projectile_basic_scn.instantiate()
	_projectiles.append(p)
	p.init(_dir, _pos, _collision)
	
	p.ground_hit.connect(func f(p): p.queue_free())
	p.player_hit.connect(on_player_hit)
	map_projectile_to_default_sounds(p)
	add_child(p, true)
	p.animated_sprite.play("sniper")
	p.radius = 2

func on_player_hit(pl:MultiplayerPlayer, p:Projectile):
	if abs(p.distance_travelled) < 0.1:
		return
	p.queue_free()
	damage.emit(_player, pl, self, abs(p.distance_travelled_x)/10 + 50)
	pl._velocity = Vector2(sign(p._dir.x)*4, -5)
	Sounds.explosion()
