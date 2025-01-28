shader_type spatial;

uniform float time_scale = 1.0; // Speed of the animation
uniform vec3 base_color = vec3(0.0, 0.5, 1.0); // Base color of the arc
uniform float glow_intensity = 2.0; // Intensity of the glow
uniform sampler2D noise_texture; // Noise texture for the arc effect

void fragment() {
    // Animate the arc using noise and time
    float noise = texture(noise_texture, vec2(UV.x * 10.0, UV.y * 10.0 - TIME * time_scale)).r;
    noise = sin(noise * 20.0 + TIME * 10.0) * 0.5 + 0.5;

    // Add glow and color
    vec3 color = base_color * noise * glow_intensity;
    ALBEDO = color;
    EMISSION = color; // Make the arc glow
    ALPHA = noise; // Fade the arc in and out
}