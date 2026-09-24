shader_type canvas_item;

// This gives you access to the background pixels
uniform sampler2D screen_texture: hint_screen_texture, filter_linear;

void vertex() {}

void fragment() {
    // Texture
    vec4 image_color = texture(TEXTURE, UV);
    
    // Background
    vec4 background_color = texture(screen_texture, SCREEN_UV);
    
	// Reversed colors
	vec3 backwards_colors = vec3(1.0 - background_color.r, 1.0 - background_color.g, 1.0 - background_color.b);
    
    // Final color
    COLOR = vec4(backwards_colors, image_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}