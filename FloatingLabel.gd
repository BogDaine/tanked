class_name FloatingLabel
extends Node2D

var amplitude = 1.6
var shake_speed = 6
var up_speed = 120
var timeout = 4

var text:String = ""
var fade:bool = false
#TODO
#preferably set text before entering the tree, maybe change thos 

var _time:float

#var _timer

func _on_timeout():
	queue_free()

func _ready() -> void:
	%label.text = text
	var timer:Timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.wait_time = timeout
	timer.autostart = true
	add_child(timer)


func _process(delta: float) -> void:
	_time+=delta
	position.x += sin(_time*shake_speed) * amplitude
	position.y -= delta * up_speed
	pass
