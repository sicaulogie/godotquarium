shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec4 mask = texture(mask_texture, UV);
    // Use the mask's brightness as alpha
    // Bright areas in mask = opaque, black areas = transparent
    float alpha = max(mask.r, max(mask.g, mask.b));
    col.a = alpha;
    COLOR = col;
}