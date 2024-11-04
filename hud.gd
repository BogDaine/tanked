extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_host_btn_pressed():
	NetworkingAutoLoad.become_host()
	self.hide()

func _on_join_btn_pressed():
	#NetworkingAutoLoad.join_game()
	self.hide()
