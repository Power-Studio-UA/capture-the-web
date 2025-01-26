shader_type spatial;
render_mode unshaded, depth_draw_never;
uniform float depth_factor: hint_range(0.0, 2.0, 0.1) = 0.5;
uniform float shift: hint_range(-5.0, 5.0, 0.1)  = 1.1;
uniform float scale: hint_range(-1.0, 1.0, 0.1)  = -0.8;
uniform float saturation_falloff: hint_range(0.0, 5.0, 0.1) = 0.8;
uniform float contrast_falloff: hint_range(0.0, 5.0, 0.1) = 0.4;
uniform float clump_intensity: hint_range(0.0, 10.0, 0.1) = 2.0;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform vec3 low_risk_color = vec3(0.0, 0.545, 0.105);
uniform vec3 high_risk_color = vec3(0.745, -0.105, -0.005);
uniform vec3 inactive_color = vec3(0.285, 0.295, 0.31);
uniform vec3 custom_color = vec3(0.0, 0.0, 0.0);

uniform float y_blend_scale: hint_range(-20.0, 20.0, 0.1)  = 0.5;
uniform float y_blend_range: hint_range(-2.0, 2.0, 0.1)  = 2.0;
uniform float y_blend_shift: hint_range(-1.0, 1.0, 0.1)  = -0.8;
uniform float risk_level: hint_range(-1.0, 1.0, 0.1)  = -1.0;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX.xy, 0.0, 1.0)).xyz;
}

void fragment() {
    float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    vec2 normalized_uv = (SCREEN_UV - 0.5) * vec2(aspect_ratio, 1.0);

    // Add clumping effect with exponential falloff
    float radial_distance = pow(length(normalized_uv), clump_intensity);

    // Decrease saturation radially
    float saturation = clamp(1.0 - radial_distance * saturation_falloff, 0.0, 1.0);

    // Adjust contrast radially
    float contrast = clamp(1.0 - radial_distance * contrast_falloff, 0.0, 1.0);

    float monochrome_radial_screen_depth = shift + scale * radial_distance;

    // Continuous interpolation based on world position
    // Map world_position.y from (-1, 1) range to (0, 1) for smooth blend
	vec3 color = mix(low_risk_color, high_risk_color, (risk_level + 0.5)/1.5);
	if (length(custom_color) > 0.05) { color = custom_color; }
    float blend_factor = min(1, max(0, (min(y_blend_range, max(-y_blend_range, world_position.y + y_blend_shift)) + 0.5 / y_blend_scale) * y_blend_range * y_blend_scale));
    vec3 final_color = mix(inactive_color, color, blend_factor) * monochrome_radial_screen_depth;

    // Desaturate
    vec3 grayscale = vec3(dot(final_color, vec3(0.299, 0.587, 0.114)));
    final_color = mix(grayscale, final_color, saturation);

    // Adjust contrast
    final_color = (final_color - 0.5) * contrast + 0.5;

    ALBEDO = final_color;
}