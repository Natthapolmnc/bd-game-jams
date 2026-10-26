shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform float outline_width : hint_range(0.001, 0.2) = 0.001;
uniform float brightness : hint_range(0.0, 1.0) = 0.30;

void fragment() {
    // Calculate distance to the nearest UV edge.
    float edge = min(
        min(UV.x, 1.0 - UV.x),
        min(UV.y, 1.0 - UV.y)
    );

    if (edge < outline_width) {
        // Solid black border.
        ALBEDO = vec3(0.0);
        ALPHA = 1.0;
    } else {
        // Transparent white overlay brightens the original texture.
        ALBEDO = vec3(1.0);
        ALPHA = brightness;
    }
}