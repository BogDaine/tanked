extends Line2D

var length = 10

func _ready() -> void:
	width = 2;
	antialiased = true

func _process(delta: float) -> void:
	global_position = Vector2.ZERO
	add_point(get_parent().global_position)
	while(get_point_count() > length):
		remove_point(0)
	#print(str(get_point_count()) + " points")
