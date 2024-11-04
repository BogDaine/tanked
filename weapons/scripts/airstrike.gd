extends Weapon

func _ready() -> void:
	var p = WeaponUtils.projectile_basic_scn.instantiate()
	_projectiles.append(p)
	p.init(_dir, _pos, _collision)
	map_projectile_to_default_sounds(p, true)
	p.set_timeout(6.0)
	p.timeout.connect(on_projectile_timeout)
	add_child(p, true)
	p.animated_sprite.play("airstrike")

func on_projectile_timeout(p:Projectile):
	p.queue_free()
	var p1:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	var p2:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	var p3:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	
	_projectiles.append(p1)
	_projectiles.append(p2)
	_projectiles.append(p3)
	
	p1.init(Vector2.ZERO, Vector2(p.position.x - 15, -20), _collision)
	p2.init(Vector2.ZERO, Vector2(p.position.x, 0), _collision)
	p3.init(Vector2.ZERO, Vector2(p.position.x + 15, -20), _collision)
	
	p1.player_hit.connect(on_player_hit)
	p2.player_hit.connect(on_player_hit)
	p3.player_hit.connect(on_player_hit)
	
	p1.ground_hit.connect(on_ground_hit)
	p2.ground_hit.connect(on_ground_hit)
	p3.ground_hit.connect(on_ground_hit)
	
	add_child(p1, true)
	add_child(p2, true)
	add_child(p3, true)
	
	p1.animated_sprite.play("projectile")
	p2.animated_sprite.play("projectile")
	p3.animated_sprite.play("projectile")

func on_ground_hit(p:Projectile):
	p.queue_free()
	_explosion_basic(p.position.x, p.position.y, 20, true, 20)

func on_player_hit(pl:MultiplayerPlayer, p:Projectile):
	p.queue_free()
	_explosion_basic(p.position.x, p.position.y, 20, true, 20)
	explode.emit(p.position.x, p.position.y + 10, 20, true)
