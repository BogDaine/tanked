extends Weapon

var _jump_limit = 5

func _ready() -> void:
	#var p:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	var p:Projectile = WeaponUtils.projectile_basic_scn.instantiate()
	_projectiles.append(p)
	
	add_child(p, true)
	
	p.init(_dir, _pos, _collision)
	map_projectile_to_default_sounds(p)
	
	p.in_ground.connect(jumpexplode)
	p.bounce.connect(jumpexplode)
	
	p.player_hit.connect(on_player_hit)
	p.animated_sprite.play("projectile")

func on_player_hit(pl:MultiplayerPlayer, p:Projectile):
	jumpexplode(p)
	_explosion_basic(p.position.x, p.position.y+10, 18)

func on_ground_hit(p:Projectile):
	jumpexplode(p)
	#p.bounce.connect(jumpexplode)
	#p.ground_hit.disconnect(on_ground_hit)
	
func jumpexplode(p:Projectile):
	_jump_limit -= 1
	_explosion_basic(p.position.x, p.position.y, 18, true, 20)
	if _jump_limit <= 0:
		p.queue_free()
	jump(p)
	
func jump(p:Projectile):
	p._dir = Vector2(0, -10)
