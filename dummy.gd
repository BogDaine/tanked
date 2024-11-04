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

func collision_normal(pos:Vector2):
	#corners
	if(pos.x == 0 and pos.y == 0):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		return Vector2.ONE.normalized()
		
	if(pos.x == width-1 and pos.y == 0):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		return Vector2(-1, 1).normalized()
		
	if(pos.x == 0 and pos.y == height-1):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		return Vector2(1, -1).normalized()
	if(pos.x == width-1 and pos.y == height-1):
		if pixels[pos.x][pos.y]:
			return Vector2.ONE
		return -Vector2.ONE.normalized()
	
	
	var normal = Vector2.ZERO
	if pos.x <= 0:
		return Vector2.RIGHT
	if pos.x >= width-1:
		return Vector2.LEFT
	if pos.y <= 0:
		return Vector2.DOWN
	if pos.y >= height-1:
		return Vector2.UP
		
	if pixels[pos.x][pos.y]:
		return Vector2.ONE
	
	var neightbor = pos + Vector2.UP
	var x = neightbor.x
	var y = neightbor.y
	
	if y >= 0:
		if pixels[x][y]:
			print("up is ground - ",  x, " ", y )
			normal += Vector2.DOWN
	
	neightbor = pos + Vector2.LEFT
	x = neightbor.x
	y = neightbor.y
	
	if x >= 0:
		if pixels[x][y]:
			print("left is ground - ",  x, " ", y )
			normal += Vector2.RIGHT
	
	neightbor = pos + Vector2.RIGHT
	x = neightbor.x
	y = neightbor.y
	
	if x < width:
		if pixels[x][y]:
			print("right is ground - ",  x, " ", y )
			normal += Vector2.LEFT
	
	neightbor = pos + Vector2.DOWN
	x = neightbor.x
	y = neightbor.y
	
	if y < height:
		if pixels[x][y]:
			print("down is ground - ",  x, " ", y )
			normal += Vector2.UP
	
	return normal.normalized()

func _ready() -> void:
	pixels = [[true , false, false, false, true],
			  [false, false, false, false, true],
			  [false, true , true , true, true],
			  [false, false, false, false, false]]
	"""
	1 0 0 0
	0 0 1 0
	0 0 1 0
	0 0 1 0
	1 1 1 0
	
	1 0 0 0 0
	0 1 0 0 0
	0 1 1 0 0
	0 0 0 0 0
	
	"""
	width = 4
	height = 5
	#print(collision_normal(Vector2(1,2)))
	print(collision_normal(Vector2(1,2)))
	#print (pixels[1*width + 2])
	#print(collision_normal(Vector2(0,0)), " ", collision_normal(Vector2(width-1,0)), " ",
	# collision_normal(Vector2(0,height-1))," " , collision_normal(Vector2(width-1,height-1)))
	#print (pixels[4], pixels[5], pixels[6], pixels[7])
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
