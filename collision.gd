class_name CollisionMap
extends Node

var height
var width
var pixels := []

func init(heights:Array, width_:int, height_:int):
	width = width_
	height = height_
	
	for x in range(width):
		pixels.append([])
		for y in range(height):
			if(heights[x] < y):
				pixels[x].append(true)
			else:
				pixels[x].append(false)
	init_bounds()
	
func init_bounds():
	var rectangle = RectangleShape2D.new()
	var bounds_width = width + 4
	var bounds_height = height + 2999
	
	rectangle.size = Vector2(bounds_width, bounds_height)
	%Bounds.position = Vector2(bounds_width/2, -((bounds_height/2) - height) + 16)
	var c:CollisionShape2D = CollisionShape2D.new()
	c.set_deferred("shape", rectangle)
	%Bounds.add_child(c)
	
	

func collision_normal(pos:Vector2, ignore_bounds:bool = true)->Vector2:
	#corners
	if(pos.x == 0 and pos.y == 0):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		if ignore_bounds:
			return Vector2.ZERO
		return Vector2.ONE.normalized()
		
	if(pos.x == width-1 and pos.y == 0):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		if ignore_bounds:
			return Vector2.ZERO
		return Vector2(-1, 1).normalized()
		
	if(pos.x == 0 and pos.y == height-1):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		if ignore_bounds:
			return Vector2.UP
		return Vector2(1, -1).normalized()
		
	if(pos.x == width-1 and pos.y == height-1):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		if ignore_bounds:
			return Vector2.UP
		return -Vector2.ONE.normalized()
	
	var normal = Vector2.ZERO
	
	if !ignore_bounds:
		if pos.x <= 0:
			return Vector2.RIGHT
		if pos.x >= width - 1:
			return Vector2.LEFT
	"""
		if pos.x < 0:
			normal += Vector2.ZERO
		if pos.x == width - 1:
			normal += Vector2.ZERO
	"""

#TODO: maybe add option to not ignore ceiling
	if pos.y < 0:
		if ignore_bounds:
			return Vector2.ZERO
		return Vector2.ZERO
		
	if pos.y >= height-1:
		return Vector2.UP
	
	if pos.x < 0 || pos.x > width - 1:
		return Vector2.ZERO
	
	if pixels[pos.x][pos.y]:
		return Vector2.ONE
	
	var neightbor = pos + Vector2.UP
	var x = neightbor.x
	var y = neightbor.y
	
	var has_adjacent_ground = true
	
	if y >= 0:
		if pixels[x][y]:
			#print("up is ground - ",  x, " ", y )
			normal += Vector2.DOWN
			has_adjacent_ground = true
	
	neightbor = pos + Vector2.LEFT
	x = neightbor.x
	y = neightbor.y
	
	if x >= 0:
		if pixels[x][y]:
			#print("left is ground - ",  x, " ", y )
			normal += Vector2.RIGHT
			has_adjacent_ground = true
	
	neightbor = pos + Vector2.RIGHT
	x = neightbor.x
	y = neightbor.y
	
	if x < width:
		if pixels[x][y]:
			#print("right is ground - ",  x, " ", y )
			normal += Vector2.LEFT
			has_adjacent_ground = true
	
	neightbor = pos + Vector2.DOWN
	x = neightbor.x
	y = neightbor.y
	
	if y < height:
		if pixels[x][y]:
			#print("down is ground - ",  x, " ", y )
			normal += Vector2.UP
			has_adjacent_ground = true
	
	if has_adjacent_ground:
		return normal.normalized()
	#-----------
	
	neightbor = pos + Vector2(-1, -1)
	x = neightbor.x
	y = neightbor.y
	if x >= 0 and y >= 0:
		if pixels[x][y]:
			#print("up-left is ground - ",  x, " ", y )
			normal += -Vector2(-1, -1)
	

	neightbor = pos + Vector2(1, -1)
	x = neightbor.x
	y = neightbor.y
	if x < width and y >= 0:
		if pixels[x][y]:
			#print("up-right is ground - ",  x, " ", y )
			normal += -Vector2(1, -1)
	
	neightbor = pos + Vector2(1, 1)
	x = neightbor.x
	y = neightbor.y
	if x < width and y < height:
		if pixels[x][y]:
			#print("down-right is ground - ",  x, " ", y )
			normal += -Vector2(1, 1)
	
		neightbor = pos + Vector2(-1, 1)
	x = neightbor.x
	y = neightbor.y
	if x >= 0 and y < width:
		if pixels[x][y]:
			#print("down-left is ground - ",  x, " ", y )
			normal += -Vector2(-1, 1)
	
	
	return normal.normalized()

func _ready() -> void:
	pass # Replace with function body.

func explode(pos_x:float, pos_y:float, radius:float):
	var x
	var y
	for i in range(-radius, radius):
		x = pos_x + i
		for j in range(-radius, radius):
			y = pos_y + j
			if x >=0 and y >= 0 and x < width and y < height:
				if (pos_x - x)**2 +(pos_y - y) ** 2 < radius**2:
					pixels[x][y] = false
	
	#TODO: make this a signal
	#get_parent().explode(pos_x, pos_y, radius)

func _process(delta: float) -> void:
	pass
