#class_name
extends Node

@export var input_dir:int = 0
@export var angle_change:int = 0
@export var shoot_strength_change:int = 0
@export var _mouse_pos:= Vector2.ZERO
@export var _aim_pos:Vector2 = Vector2.ZERO
@export var _shoot_dir:= Vector2(0.5, 0.5).normalized()

signal aim_pos_changed()
signal shoot_signal()

func _ready() -> void:
	pass 

func input_move():
	
	input_dir = 0
	if(Input.is_action_pressed("move_left")):
		input_dir = -1
	if(Input.is_action_pressed("move_right")):
		input_dir = +1

func input_angle():
	
	angle_change = 0
	if(Input.is_action_pressed("angle_minus")):
		angle_change = -1
	if(Input.is_action_pressed("angle_plus")):
		angle_change = +1

func input_shoot_strength():
	
	shoot_strength_change = 0
	if(Input.is_action_pressed("strength_down")):
		shoot_strength_change = -1
	if(Input.is_action_pressed("strength_up")):
		shoot_strength_change = +1


func input_shoot():
	if Input.is_action_just_pressed("ui_accept"):
		shoot_signal.emit()


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_mouse_pos = get_viewport().get_mouse_position()
		input_shoot()
		input_move()
		input_shoot_strength()
		input_angle()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_aim_pos = _mouse_pos
			aim_pos_changed.emit()
			
		
