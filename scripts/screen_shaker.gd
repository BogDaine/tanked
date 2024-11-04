class_name ScreenShaker
extends CanvasItem

func stop_shake():
	material.set_shader_parameter("shake", false);

func shake(duration:float = 0.2, amplitude = 0.0035, speed = 64):
	material.set_shader_parameter("amplitude", amplitude);
	material.set_shader_parameter("speed", speed);
	material.set_shader_parameter("shake", true);
	
	var timer:Timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(stop_shake)
	timer.wait_time = duration
	timer.autostart = true
	add_child(timer)
	

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
