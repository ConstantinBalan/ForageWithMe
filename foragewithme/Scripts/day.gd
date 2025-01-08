extends DirectionalLight3D



@export_group("Sky Colors")
@export var day_sky_color: Color = Color(0.4, 0.6, 1.0)
@export var day_horizon_color: Color = Color(0.6, 0.8, 1.0)

@export var sunset_sky_color: Color = Color(0.2, 0.1, 0.3)
@export var sunset_horizon_color: Color = Color(0.8, 0.3, 0.2)

@export var twilight_sky_color: Color = Color(0.1, 0.1, 0.2)
@export var twilight_horizon_color: Color = Color(0.3, 0.2, 0.3)

@export var night_sky_color: Color = Color(0.02, 0.02, 0.04)
@export var night_horizon_color: Color = Color(0.05, 0.05, 0.1)

# Transition angles
@export_group("Transition Angles")
@export var sunset_start_angle: float = -20.0  # When sunset begins
@export var show_stars_angle :float = -5.0 # When stars start to show
@export var twilight_start_angle: float = 10.0  # When twilight begins
@export var night_start_angle: float = 30.0    # When night begins

@export_group("Sunlight Brightness")
@export var sunlight_daytime: float = 1.0
@export var sunlight_sunset: float = 0.5
@export var sunlight_twilight: float = 0.25
@export var sunlight_night: float = 0.0

@export var star_particles: GPUParticles3D

var environment: Environment

func _ready():
	var world_environment = %WorldEnvironment
	if world_environment:
		environment = world_environment.environment
	if !environment:
		push_warning("No WorldEnvironment found.")
	environment.fog_density = 0.0



func _process(delta):
	if !environment:
		return    
	
	var current_angle = rotation_degrees.x
	var sky_color: Color
	var horizon_color: Color
	sky_color_shift(current_angle, sky_color, horizon_color)
	setup_star_particles(current_angle, delta)
	# Add to _process
	#var fog_density = remap(current_angle, sunset_start_angle, night_start_angle, 0.0, 0.03)
	#fog_density = clamp(fog_density, 0.0, 0.03)

	#environment.fog_density = fog_density
	var time = deg_to_rad(0.05)
	rotate_x(time)

func sky_color_shift(current_light_angle, sky_color, horizon_color):
	if current_light_angle <= sunset_start_angle: # Full Daytime
		sky_color = day_sky_color
		horizon_color = day_horizon_color
		light_energy = sunlight_daytime
	elif current_light_angle <= twilight_start_angle: # Sunset
		var factor = inverse_lerp(sunset_start_angle, twilight_start_angle, current_light_angle)
		sky_color = day_sky_color.lerp(sunset_sky_color, factor)
		horizon_color = day_horizon_color.lerp(sunset_horizon_color, factor)
		light_energy = lerp(sunlight_daytime, sunlight_sunset, factor)
	elif current_light_angle <= night_start_angle: # Twilight
		var factor = inverse_lerp(twilight_start_angle, night_start_angle, current_light_angle)
		sky_color = sunset_sky_color.lerp(twilight_sky_color, factor)
		horizon_color = sunset_horizon_color.lerp(twilight_horizon_color, factor)
		light_energy = lerp(sunlight_sunset, sunlight_twilight, factor)
	else:
		if current_light_angle >= 60.0: # Full time night
			sky_color = night_sky_color
			horizon_color = night_horizon_color
		else:
			var factor = inverse_lerp(night_start_angle, 60.0, current_light_angle) # Dusk
			sky_color = twilight_sky_color.lerp(night_sky_color, factor)
			horizon_color = twilight_horizon_color.lerp(night_horizon_color, factor)
			light_energy = lerp(sunlight_twilight, sunlight_night, factor)
	
	environment.sky.sky_material.set_sky_top_color(sky_color)
	environment.sky.sky_material.set_sky_horizon_color(horizon_color)

func setup_star_particles(current_light_angle, delta):
	var dawn_alpha = 0.0
	var dusk_alpha = 1.0
	if !star_particles:
		push_warning("The star particles object is not set to the 3D light")
		return
		
	var particle_material = star_particles.process_material as ParticleProcessMaterial
	
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.emission_box_extents = Vector3(500, 50, 500)
	particle_material.scale_min = 2.0
	particle_material.scale_max = 3.0
	particle_material.turbulence_enabled = true
	particle_material.turbulence_noise_strength = 0.1
	particle_material.turbulence_noise_scale = 1.0
	
	if star_particles:
		var material = star_particles.draw_pass_1.material as StandardMaterial3D
		var current_alpha = material.albedo_color.a
		var new_alpha = dawn_alpha
		# Start showing stars during twilight
		if current_light_angle >= show_stars_angle:
			new_alpha = lerp(current_alpha, dusk_alpha, delta * 0.01)
			print("making stars now")

		else:
			new_alpha = lerp(current_alpha, dawn_alpha, delta)
		
		material.albedo_color.a = new_alpha

			# Adjust emission box size based on time of day
			# This creates a nice effect of stars "appearing" from further away
			#var emission_box_size = remap(current_light_angle, twilight_start_angle, night_start_angle, 100.0, 500.0)
			#particle_material.emission_box_extents = Vector3(emission_box_size, 50.0, emission_box_size)
