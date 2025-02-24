shader_type canvas_item;

uniform float contrast : hint_range(0.0, 3.0) = 1.2; // Adjust this value as needed
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Get the current screen color
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Adjust contrast: (color - 0.5) * contrast + 0.5
    screen_color.rgb = ((screen_color.rgb - 0.5) * contrast + 0.5);

    COLOR = screen_color;
}
