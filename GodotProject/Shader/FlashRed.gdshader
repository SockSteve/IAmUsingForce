shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform vec3 shock_color = vec3(1.0, 0.0, 0.0); // Red flash color

void fragment() {
    float time_factor = mod(TIME, 3.0);
    float intensity = exp(-15.0 * time_factor); // Controls fade-out effect

    // Apply the shock color with fading intensity
    ALBEDO = shock_color;
    ALPHA = intensity; // Fade effect using alpha
    EMISSION = shock_color * intensity * 2.0; // Boost glow for visibility
}