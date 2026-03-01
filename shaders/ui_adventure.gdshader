shader_type canvas_item;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float mask = 1.0 - smoothstep(0.75, 1.0, UV.y);
    COLOR = vec4(tex.rgb, tex.a * mask);
}
