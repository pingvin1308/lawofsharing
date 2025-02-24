shader_type canvas_item;

// Base background color (deep space)
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.1, 1.0);
// Color for the blackhole center
uniform vec4 blackhole_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Adjust the size of the blackhole (as a fraction of the screen)
uniform float blackhole_radius = 0.25;
// How strong the swirl distortion is around the blackhole
uniform float swirl_strength = 1.0;

// Set this to match your game’s pixel resolution (for pixelation)
uniform vec2 resolution = vec2(320.0, 240.0);

void fragment() {
    // Normalize the fragment coordinates (0.0 to 1.0)
    vec2 uv = FRAGCOORD.xy / resolution;

    // Pixelate UV coordinates for a crisp pixel art look
    float pixel_size = 1.0 / resolution.x;
    uv = floor(uv / pixel_size) * pixel_size;

    // Center coordinates (assumes blackhole is at screen center)
    vec2 center = vec2(0.5);
    vec2 pos = uv - center;
    float dist = length(pos);

    // Calculate the angle for the current pixel
    float angle = atan(pos.y, pos.x);

    // Compute a swirl effect that increases as we approach the blackhole edge
    // The swirl is stronger near the blackhole and fades away farther out.
    float swirl = mix(0.0, swirl_strength, smoothstep(blackhole_radius, blackhole_radius * 0.5, dist));
    float new_angle = angle + swirl;

    // Get new position based on the swirled angle
    vec2 new_pos = vec2(cos(new_angle), sin(new_angle)) * dist;
    vec2 uv_swirl = new_pos + center;

    // Use a smoothstep to create a radial gradient for the blackhole:
    // Pixels inside the blackhole_radius become fully black.
    float hole = smoothstep(blackhole_radius, blackhole_radius - 0.05, dist);

    // Mix the base background with the blackhole color based on the gradient
    vec4 color = mix(bg_color, blackhole_color, hole);

    // Optionally, you can sample a texture or add stars here for extra depth.

    COLOR = color;
}
