// Flashing Shader
// Overlays/Mixes between an animated color A and color B (alpha of each controls mix amount)
shader_type canvas_item;

instance uniform bool is_using_skill = false;
instance uniform bool used_skill = false;

// Color A: grey by default
uniform vec4 color_a:source_color = vec4(0.7, 0.7, 0.7, 1.0);

// Color B: White by default
uniform vec4 color_b:source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Whether to enable the animation or simply mix in color_a only
uniform float flash_amount:hint_range(0.0, 1.0, 0.1) = 1.0;

// if flash_amount is true, flash_speed controls the speed of the animation between color_a and color_b
uniform float flash_speed = 1.0;

// transparency, like modulate
uniform float transparency:hint_range(0.0, 1.0, 0.01) = 1.0;

// Intensity of the shader
uniform float intensity:hint_range(0.0, 1.0, 0.1) = 1.0;


float anim() {
	return (sin(TIME * flash_speed) + 1.0) / 2.0;
}

// returns a mix between color_a and color_b, based on TIME
// see the anim() function
vec4 get_shader_color() {
	if (flash_amount > 0.0) {
		float f = anim();
		return mix(color_a, color_b, f * flash_amount);
	}else {
		return color_a;
	}
}

void fragment() {
	// get input color and alpha from the texture
	vec4 in_color = texture(TEXTURE, UV);
	float in_alpha = in_color.a;
	
	if (is_using_skill) {
		// get the shader color (some mix between color_a and color_b)
		vec4 shader_rgba = get_shader_color();
		vec3 shader_color = shader_rgba.rgb;
		float shader_alpha = shader_rgba.a;

		// rgb color mixes between in_color and shader_color * by shader_alpha
		// this way, color_a can have a different "intensity" than color_b
		//
		// wrap in vec4 and plug in the in_alpha since we don't generally want to retain that from the texture
		vec4 out_color = vec4(mix(in_color.rgb, shader_color, shader_alpha), in_alpha);

		out_color.a *= transparency;

		// finally, use mix to control intensity of the entire effect
		COLOR = mix(in_color, out_color, intensity);
	}
	else if (used_skill) {
		vec4 shader_rgba = mix(in_color, vec4(0,0,0,1), 0.5);
		vec3 shader_color = shader_rgba.rgb;
		float shader_alpha = shader_rgba.a;

		// rgb color mixes between in_color and shader_color * by shader_alpha
		// this way, color_a can have a different "intensity" than color_b
		//
		// wrap in vec4 and plug in the in_alpha since we don't generally want to retain that from the texture
		vec4 out_color = vec4(mix(in_color.rgb, shader_color, shader_alpha), in_alpha);
		out_color.a *= transparency;
		
		COLOR = mix(in_color, out_color, intensity);
	}
}
// Revist later
//instance uniform float damage_direction:hint_range(-1.0, 1.0, 2.0) = 1.0;
//void vertex() {
	//VERTEX.x = VERTEX.x + (-15.0 * damage_direction * (sin(TIME* 8.0) + 1.0));
//}