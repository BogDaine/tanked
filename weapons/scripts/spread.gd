extends Weapon

@export var count:int = 5
@export var angle_dif:float = 0.05
@export var weapon:String = "smol boi"

func _ready() -> void:
	for i in range(count):
		var w:Weapon = GameGlobalsAutoload.weapon_scene_by_name(weapon).instantiate()
		w.damage.connect(_relay_damage)
		w.explode.connect(_relay_explode)
		w.init(_dir.rotated(i*angle_dif), _pos,_collision, _player)
		add_child(w, true)
		_weapons.append(w)
