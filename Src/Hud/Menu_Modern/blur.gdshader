// Aero-Style Window Shader
shader_type canvas_item;

uniform float blur_factor: hint_range(0.0, 5.0) = 1.0;
uniform vec4 color: source_color;
uniform float blur_amount : hint_range(0.0, 2.0) = 0.5;
uniform float color_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 blur_color = texture(SCREEN_TEXTURE, SCREEN_UV, blur_factor) * blur_amount;
	COLOR = blur_color + color * (1.0 - color_amount);
}