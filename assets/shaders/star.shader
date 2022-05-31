shader_type canvas_item;

uniform vec4 obtained : hint_color = vec4(1.0);
uniform vec4 not_obtained : hint_color = vec4(0.0);

uniform float cut: hint_range(0, 1);


void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (UV.x <= cut) {
		COLOR = tex * obtained;
	} else {
		COLOR = tex * not_obtained;
	}
}