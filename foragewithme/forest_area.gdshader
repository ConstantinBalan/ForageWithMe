shader_type spatial;


void vertex() {
	if (VERTEX.y > 0.3){
		VERTEX.x += sin(TIME * 5.0 + VERTEX.y) * 0.03;
		VERTEX.z += sin(TIME * 3.0) * 0.2 ;
		}
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 color;
	color.r = 0.5;
	color.g = 0.0;
	color.b = 0.0;
	ALBEDO = vec3(color.r,color.g,color.b);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
