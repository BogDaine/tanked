shader_type canvas_item;
uniform float ratio:hint_range(0, 1);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 new_UV = vec2(UV.x-0.5, UV.y-0.5);
	COLOR = vec4(new_UV, 0.f, 1.0f);
	vec4 c = texture(TEXTURE, vec2(UV.x, UV.y)) * ((2.f * ratio)-distance(vec2(0.5f, 0.5f), UV));
	if(length(c) >= 2.4f)
		discard;
	
	float margin = abs(length(c)-2.4f);
	if(margin > 0.05 && margin < 0.32)
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	else
	COLOR = c;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
