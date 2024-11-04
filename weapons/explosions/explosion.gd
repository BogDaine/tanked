class_name Explosion
extends Node2D

@onready var _area:Area2D = $Area2D

var radius:float = 10:
	set(value):
		var circle = CircleShape2D.new()
		circle.radius = radius
		set_shape(circle)
		radius = value
	

var ignore_players:Array[MultiplayerPlayer]
signal player_hit(p:MultiplayerPlayer, e:Explosion)

func set_shape(shape:Shape2D):
	if !is_instance_valid(_area):
		printerr("explosion area accessed too early perhaps")
		return
		
	for child in _area.get_children():
		_area.remove_child(child)
		
	var c:CollisionShape2D = CollisionShape2D.new()
	c.set_deferred("shape", shape)
	_area.add_child(c)
	
func set_timeout(t:float):
	var timer:Timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(on_timeout)
	timer.wait_time = t
	timer.autostart = true
	add_child(timer)

#TODO: MultiplayerPlayer inherits player! :)

func add_ignore_player(p:MultiplayerPlayer):
	if is_instance_valid(p):
		ignore_players.append(p)
	
func _ready() -> void:
	_area.area_entered.connect(on_area_entered)

func _draw():
	#DEBUG
	draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.099))
	
func on_area_entered(a:Area2D):
	var p = a.get_parent()
	#print(p.name)
	if p is MultiplayerPlayer:
		if ignore_players.has(p):
			return
		player_hit.emit(p, self)
		add_ignore_player(p)

func on_timeout():
	queue_free()

var time = 0
func _physics_process(delta: float) -> void:
	time += delta
	position.y += cos(time*32)*0.5
	#wiggle so it detects collisions better...
