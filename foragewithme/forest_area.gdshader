shader_type spatial;

uniform vec3 top_color : source_color = vec3(0.5, 1.0, 0.47);    // Green
uniform vec3 bottom_color : source_color = vec3(1.0, 0.58, 0.24); // Brown
uniform float transition_offset = 0.7;  // Controls where the middle of the gradient appears
uniform float transition_smoothness = 5.0;  // Controls how sharp the gradient is

void fragment() {
    // Create a smoothed and offset gradient
    float gradient = clamp((UV.y - transition_offset) * transition_smoothness + 0.5, 0.0, 1.0);
    
    vec3 final_color = mix(bottom_color, top_color, gradient);
    
    ALBEDO = final_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
