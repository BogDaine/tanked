class_name Map
extends Node

@onready var sprite:Sprite2D = $FG
@onready var texture = sprite.texture
@onready var image:Image = texture.get_image()
@onready var _collision = $Collision

@export var seed:int

const TRANSPARENT = Color("#56433f", 0.0)

var heights = []
var _width
var _height

func _enter_tree() -> void:
	get_parent().set("_map", self)
	GameGlobalsAutoload._map = self

func generate_map():
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.fractal_octaves = 2
	noise.offset = Vector3(0, 0, 0)
	noise.frequency = 4

	
	_width = image.get_width()
	_height = image.get_height()
	
	var new_image = Image.create(_width, _height, false, Image.FORMAT_RGBAF)
	
	for x in range(_width):
		for y in range(_height):
			var old_color = image.get_pixel(x, y)
			var color = old_color.to_html()
			new_image.set_pixel(x, y, color)
	
	for x in range(_width):
		var terrain_height = (noise.get_noise_1d(float(x)/float(_width))+1) * _height * 0.5
		heights.append(terrain_height)
		for y in range(terrain_height):
			new_image.set_pixel(x, y, TRANSPARENT)
	for x in range(_width):
		var terrain_height = (noise.get_noise_1d(float(x)/float(_width))+1) * _height * 0.5
		heights.append(terrain_height)
	
	_collision.init(heights, _width, _height)
	print(_width, " ", _height)
	"for x in range(_width):
		var terrain_height = (noise.get_noise_1d(float(x)/float(_width))+1) * _height * 0.5
		for y in range(_height):
			var old_color = image.get_pixel(x, y)
			var color = old_color.to_html()
			#new_image.set_pixel(x, y, color)
			var normal = collision.collision_normal(Vector2(x,y))
			if normal.x < 0 and normal.y < 0:
				color = Color(0.0, 0.0, 1.0, 1.0)
				#^<-
			if normal.x < 0 and normal.y > 0:
				#_<-
				color = Color(0.0, 1.0, 0.0, 1.0)
			#if normal.x > 0 and normal.y < 0:
				#->^
				#color = Color(1.0, 0.0, 0.0, 1.0)
			if normal.x > 0 and normal.y > 0:
				color = Color(0.5, 0.5, 0.5, 1.0)
				#->_
			if normal.y == 0 and normal.x != 0:
				color = Color(1.0, 0.0, 1.0, 1.0)
			new_image.set_pixel(x, y, color)
	"
	"
	for x in range(width):
		var terrain_height = (noise.get_noise_1d(float(x)/float(width))+1) * height * 0.5
		for y in range(terrain_height):
			new_image.set_pixel(x, y, TRANSPARENT)
	"

	var tex = ImageTexture.create_from_image(new_image)
	sprite.texture = tex
	
func _ready() -> void:
	generate_map()

func explode(pos_x:float, pos_y:float, radius:float):
	_collision.explode(pos_x, pos_y, radius)
	var x
	var y
	var new_image = sprite.texture.get_image()
	for i in range(-radius, radius):
		x = pos_x + i
		for j in range(-radius, radius):
			y = pos_y + j
			if x >=0 and y >= 0 and x < _width and y < _height:
				if (pos_x - x)**2 +(pos_y - y) ** 2 < radius**2:
					new_image.set_pixel(x, y, TRANSPARENT)
	var tex = ImageTexture.create_from_image(new_image)
	sprite.texture = tex
	var t = Texture2D.new()
	
				
func _process(delta: float) -> void:
	pass
