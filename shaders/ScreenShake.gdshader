shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform bool shake = false;
uniform float amplitude = 0.01;
uniform float speed = 64.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(shake)
		COLOR = textureLod(screen_texture, SCREEN_UV + amplitude* vec2(sin(TIME*speed), sin(TIME*speed)), 0.0);// * vec4(1.0, 1.0, 1.0, 0.5);
	else discard;
	//COLOR = vec4(0.0, 0.0, 0.0, 0.4);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
