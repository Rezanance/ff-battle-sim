shader_type spatial;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Sample the original sprite texture
    vec4 tex_color = texture(UV);

    // Multiply the texture color by the tint color
    COLOR = tex_color * tint_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
