extends Node

@export var _map:Map
var camera:Camera2D = null
var screen_shaker:ScreenShaker = null

var weapon_index = {}
var weapon_descriptions = [
	{"name":"smol boi",
	"icon": preload("res://weapons/descriptions/smol_boi.png"),
	"tooltip":"Just a small boi. Explodes on hit :)",
	"scene":preload("res://weapons/SmolBoi.tscn")},
	
	{"name":"grenade",
	"icon": preload("res://weapons/descriptions/grenade.png"),
	"tooltip":"Some people may get impatient.\n That is when true spirit must emerge.",
	"scene":preload("res://weapons/grenade.tscn")},
	
	{"name":"breaker",
	"icon": preload("res://weapons/sprites/breaker.png"),
	"tooltip":"splits on impact, just like myself",
	"scene":preload("res://weapons/Breaker.tscn")},
	
	{"name":"airstrike",
	"icon": preload("res://weapons/sprites/airstrike.png"),
	"tooltip":"nyyyeeeeeaaawwwww",
	"scene":preload("res://weapons/Airstrike.tscn")},
	
	{"name":"sniper",
	"icon": preload("res://weapons/descriptions/sniper.png"),
	"tooltip":"Just aim well;\nthings will take care of themselves.",
	"scene":preload("res://weapons/sniper.tscn")},
	
	{"name":"grenade launcher",
	"icon": preload("res://weapons/descriptions/grenade.png"),
	"tooltip":"Launches grenades. Duh!",
	"scene":preload("res://weapons/grenade_launcher.tscn")},
	
	{"name":"digger",
	"icon": preload("res://weapons/descriptions/smol_boi.png"),
	"tooltip":"You've dug yourself into a hole :O",
	"scene":preload("res://weapons/digger.tscn")},
	
	{"name":"5-spread",
	"icon": preload("res://weapons/descriptions/smol_boi.png"),
	"tooltip":"Quintuplets??!!",
	"scene":preload("res://weapons/5_spread.tscn")},
]

func init_weapon_lists():
	for i in range(weapon_descriptions.size()):
		weapon_index[weapon_descriptions[i]["name"]] = i

func init():
	init_weapon_lists()

func weapon_scene_by_name(w_name:String) -> PackedScene:
	return weapon_descriptions[weapon_index[w_name]]["scene"]

func shake_screen(duration:float = 0.2, amplitude = 0.0035, speed = 64):
	if screen_shaker == null: return
	screen_shaker.shake(duration, amplitude, speed)

func _process(delta: float) -> void:
	pass
func _ready() -> void:
	init()
