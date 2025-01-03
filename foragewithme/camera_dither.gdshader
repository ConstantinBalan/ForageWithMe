shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D dither_pattern : filter_nearest;
uniform sampler2D color_palette : filter_nearest;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.5;
uniform int palette_size = 8;  // How many colors are in your palette texture

// This function finds the closest color in our palette to a given color
vec3 find_closest_palette_color(vec3 input_color) {
    // We'll track the closest color we've found
    float closest_distance = 999999.0;
    vec3 closest_color = input_color;
    
    // Look through each color in our palette
    for (int i = 0; i < palette_size; i++) {
        // Sample from the center of each palette color to avoid bleeding
        vec2 palette_uv = vec2((float(i) + 0.5) / float(palette_size), 0.5);
        vec3 palette_color = texture(color_palette, palette_uv).rgb;
        
        // Calculate how different this palette color is from our input
        float distance = length(palette_color - input_color);
        
        // If this is the closest match so far, remember it
        if (distance < closest_distance) {
            closest_distance = distance;
            closest_color = palette_color;
        }
    }
    
    return closest_color;
}

void fragment() {
    // Get the current screen color
    vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Apply our dither pattern
    vec2 dither_uv = SCREEN_UV * SCREEN_PIXEL_SIZE * 8.0;
    float dither = texture(dither_pattern, mod(dither_uv, vec2(1.0))).r - 0.5;
    
    // Add the dither pattern to our color
    vec3 dithered = screen.rgb + vec3(dither * dither_strength);
    
    // Now find the closest color in our palette
    vec3 final_color = find_closest_palette_color(dithered);
    
    // Output the result
    COLOR = vec4(final_color, screen.a);
}