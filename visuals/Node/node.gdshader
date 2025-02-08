shader_type spatial;
render_mode unshaded, depth_draw_never;

// Global parameters that will be shared across all instances
uniform float depth_factor: hint_range(0.0, 2.0, 0.1) = 0.5;
uniform float shift: hint_range(-5.0, 5.0, 0.1) = 1.1;
uniform float scale: hint_range(-1.0, 1.0, 0.1) = -0.8;
uniform float saturation_falloff: hint_range(0.0, 5.0, 0.1) = 0.8;
uniform float contrast_falloff: hint_range(0.0, 5.0, 0.1) = 0.4;
uniform float clump_intensity: hint_range(0.0, 10.0, 0.1) = 2.0;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform float y_blend_scale: hint_range(-40.0, 40.0, 0.1) = 0.5;
uniform float y_blend_range: hint_range(-2.0, 2.0, 0.001) = 2.0;
uniform float y_blend_shift: hint_range(-1.0, 1.0, 0.001) = -0.8;
uniform vec3 override_color: source_color = vec3(0.0, 0.0, 0.0);

// Predefined inactive color used for height-based blending
const vec3 INACTIVE_COLOR = vec3(0.285, 0.295, 0.31);

varying vec3 world_position;

void vertex() {
    // Calculate the world-space position for use in the fragment shader
    world_position = (MODEL_MATRIX * vec4(VERTEX.xy, 0.0, 1.0)).xyz;
}

void fragment() {
    // Compute normalized screen coordinates taking the aspect ratio into account
    float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    vec2 normalized_uv = (SCREEN_UV - 0.5) * vec2(aspect_ratio, 1.0);

    // Apply a clumping effect with an exponential falloff
    float radial_distance = pow(length(normalized_uv), clump_intensity);

    // Radial falloff for saturation and contrast
    float saturation = clamp(1.0 - radial_distance * saturation_falloff, 0.0, 1.0);
    float contrast = clamp(1.0 - radial_distance * contrast_falloff, 0.0, 1.0);
    float monochrome_radial_screen_depth = shift + scale * radial_distance;

    // Use the vertex color directly as the base color
    vec3 base_color = COLOR.rgb;
	if (length(override_color) > 0.0) {
	    base_color = override_color;
	}
    // Modify the color based on world-space Y (height)
    float blend_factor = min(1.0, max(0.0,
        (min(y_blend_range, max(-y_blend_range, world_position.y + y_blend_shift)) + 0.5 / y_blend_scale)
         * y_blend_range * y_blend_scale));
    vec3 final_color = mix(INACTIVE_COLOR, base_color, blend_factor) * monochrome_radial_screen_depth;

    // Apply desaturation based on the radial effect
    vec3 grayscale = vec3(dot(final_color, vec3(0.299, 0.587, 0.114)));

    final_color = mix(grayscale, final_color, saturation);


    // Adjust contrast
    final_color = (final_color - 0.5) * contrast + 0.5;

    ALBEDO = final_color;
}
