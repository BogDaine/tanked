extends Weapon


func _ready() -> void:
	var p:Projectile = projectile_basic_scn.instantiate()
	_projectiles.append(p)
	p.init(_dir, _pos, _collision)
	map_projectile_to_default_sounds(p, true)
	p.ground_hit.connect(projectile_explode)
	p.player_hit.connect(on_player_hit)
	p.set_tick(0.3)
	p.tick.connect(launch_grenade)
	add_child(p, true)
	p.animated_sprite.play("grenade")
	
func launch_grenade(p:Projectile):
	#var g = GameGlobalsAutoload.weapon_scene_by_name("grenade").instantiate()
	#_weapons.append(g)
	#g.init(p._dir*0.2, p.position, _collision, _player)
	#add_child(g, true)
	var p_new:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	_projectiles.append(p_new)
	p_new.init( p._dir * 0.2, p.position, _collision)
	map_projectile_to_default_sounds(p_new, true)
	p_new.set_timeout(4.0)
	p_new.timeout.connect(projectile_explode)
	add_child(p_new, true)
	p_new.animated_sprite.play("grenade")
	
func on_player_hit(pl:MultiplayerPlayer, p:Projectile):
	projectile_explode(p)
	_explosion_basic(p.position.x, p.position.y, 25)
func projectile_explode(p:Projectile):
	_explosion_basic(p.position.x, p.position.y, 18, true, 35)
	p.queue_free()
