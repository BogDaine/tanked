class_name PlayerUI

extends Control

var _player:MultiplayerPlayer = null

var _mouse_is_over:bool = false
var _left_click_pressed:bool = false

func _ready() -> void:
	setup_weapon_list()

func setup_weapon_list():
	var i:int = 0
	for w in GameGlobalsAutoload.weapon_descriptions:
		%WeaponList.add_item(w["name"], w["icon"])
		%WeaponList.set_item_tooltip(i, w["tooltip"])
		i+=1
	%WeaponList.item_selected.connect(_on_weapon_selected)

var old_strength = -1
func _process(delta: float) -> void:
	if _player == null: return
	if abs(old_strength - _player._shoot_strength) > 0.01:
		old_strength = _player._shoot_strength
		%StrengthLabel.text = str(_player._shoot_strength)
		%StrengthSlider.value = _player._shoot_strength/_player._max_shoot_strength * 100
		
func _on_fire_btn_pressed() -> void:
	if _player == null: return
	_player._on_shoot_signal()
	
#this prevents keyboard input on UI :)
func _input(event: InputEvent) -> void:
	#print(event.is_action_pressed("left_click"))
	if event.is_action("left_click"):
		if !_mouse_is_over:
			enable_player_mouse()
			
		if event.is_action_pressed("left_click"):
			_left_click_pressed = true
		if event.is_action_released("left_click"):
			_left_click_pressed = false
			if _mouse_is_over:
				disable_player_mouse()

func _on_weapon_selected(index:int):
	if _player == null: return
	_player.weapon_index = index
func _on_mouse_entered():
	_mouse_is_over = true
	if !_left_click_pressed:
		disable_player_mouse()

func _on_mouse_exited():
	_mouse_is_over = false
	
func disable_player_mouse() -> void:
	if _player == null: return
	_player.ignore_mouse = true


func enable_player_mouse() -> void:
	if _player == null: return
	_player.ignore_mouse = false


var old_slider_value:float = 0
func _on_strength_slider_value_changed(value: float) -> void:
	if _player == null: return
	if _player.disabled:
		%StrengthSlider.value = old_slider_value
	else:
		_player._shoot_strength = value/100 * _player._max_shoot_strength
		old_slider_value = value