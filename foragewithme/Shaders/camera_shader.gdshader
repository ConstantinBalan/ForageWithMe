shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 1.0;

void fragment() {
    // SCREEN_UV gives us the current pixel's position on screen (0-1 range)
    // We multiply by 1.0/SCREEN_PIXEL_SIZE to get actual pixel coordinates
    vec2 pixel_position = SCREEN_UV / SCREEN_PIXEL_SIZE;

    // Round down to the nearest pixel_size multiple
    // This creates the pixelation effect by making groups of pixels sample from the same position
    pixel_position = floor(pixel_position / pixel_size) * pixel_size;

    // Convert back to UV coordinates by multiplying by pixel size
    vec2 pixelated_uv = pixel_position * SCREEN_PIXEL_SIZE;

    // Sample the screen texture at our pixelated position
    COLOR = texture(SCREEN_TEXTURE, pixelated_uv);
}