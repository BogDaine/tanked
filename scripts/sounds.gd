extends Node

@onready var _sound_node_scn = preload("res://scenes/SoundNode.tscn")
@onready var _sound_node:SoundNode = _sound_node_scn.instantiate()

func _ready():
	add_child(_sound_node)
	
func shoot():
	_sound_node.shoot()
func explosion():
	_sound_node.explosion()
func bounce():
	_sound_node.bounce()
func out_of_bounds():
	_sound_node.out_of_bounds()
func split():
	_sound_node.split()
