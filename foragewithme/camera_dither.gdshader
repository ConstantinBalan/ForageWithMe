shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D dither_pattern : filter_nearest;
uniform sampler2D color_palette : filter_nearest;
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 1.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.5;
uniform int palette_size = 8;

// Function to find the closest color in our palette
vec3 find_closest_palette_color(vec3 input_color) {
    float closest_distance = 999999.0;
    vec3 closest_color = input_color;

    for (int i = 0; i < palette_size; i++) {
        vec2 palette_uv = vec2((float(i) + 0.5) / float(palette_size), 0.5);
        vec3 palette_color = texture(color_palette, palette_uv).rgb;
        float distance = length(palette_color - input_color);

        if (distance < closest_distance) {
            closest_distance = distance;
            closest_color = palette_color;
        }
    }

    return closest_color;
}

void fragment() {
    // Step 1: Pixelate the image
    vec2 pixel_position = SCREEN_UV / SCREEN_PIXEL_SIZE;
    pixel_position = floor(pixel_position / pixel_size) * pixel_size;
    vec2 pixelated_uv = pixel_position * SCREEN_PIXEL_SIZE;
    vec4 pixelated = texture(SCREEN_TEXTURE, pixelated_uv);

    // Step 2: Apply dithering to the pixelated result
    vec2 dither_uv = pixelated_uv * SCREEN_PIXEL_SIZE * 8.0;
    float dither = texture(dither_pattern, mod(dither_uv, vec2(1.0))).r - 0.5;

    // Step 3: Apply dithering and find closest palette color
    vec3 dithered = pixelated.rgb + vec3(dither * dither_strength);
    vec3 final_color = find_closest_palette_color(dithered);

    COLOR = vec4(final_color, pixelated.a);
}