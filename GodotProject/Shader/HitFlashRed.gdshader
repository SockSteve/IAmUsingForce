shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform vec3 flash_color = vec3(1.0, 0.0, 0.0); // Red flash color
uniform float flash_time = 100.0;

void fragment() {
	float time_factor_b = mod(TIME, 3.0);
	//float intensity = 0.0;
    float intensity = exp(-15.0 * flash_time); // Controls fade-out effect

    // Apply the shock color with fading intensity
    ALBEDO = flash_color;
    ALPHA = intensity; // Fade effect using alpha
    EMISSION = flash_color * intensity * 2.0; // Boost glow for visibility
}