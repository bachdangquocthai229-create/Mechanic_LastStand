shader_type canvas_item;

uniform sampler2D normal_map : hint_normal;

void fragment() {
    NORMAL = texture(normal_map, UV).rgb * 2.0 - 1.0;
}
