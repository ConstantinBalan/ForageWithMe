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
@export var twilight_start_angle: float = 10.0  # When deep twilight begins
@export var night_start_angle: float = 30.0    # When full night begins

@export_group("Sunlight Brightness")
@export var sunlight_daytime: float = 1.0
@export var sunlight_sunset: float = 0.5
@export var sunlight_twilight: float = 0.25
@export var sunlight_night: float = 0.0

@export var star_particles: GPUParticles3D

# Reference to the environment (we'll set this in _ready)
var environment: Environment

# Called when the node enters the scene tree for the first time.
func _ready():
	var world_environment = %WorldEnvironment
	if world_environment:
		environment = world_environment.environment
	if !environment:
		push_warning("No WorldEnvironment found.")
	environment.fog_density = 0.0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !environment:
		return    
	
	var current_angle = rotation_degrees.x
	var sky_color: Color
	var horizon_color: Color
	# Add to _process
	var fog_density = remap(current_angle, sunset_start_angle, night_start_angle, 0.0, 0.03)
	fog_density = clamp(fog_density, 0.0, 0.03)
	if star_particles:
		# Start showing stars during twilight
		if current_angle <= twilight_start_angle:
			# Stars completely invisible during day
			star_particles.visible = false
		else:
			print("making stars now")
			# Make stars visible and control their fade-in
			star_particles.visible = true
			# Adjust emission box size based on time of day
			# This creates a nice effect of stars "appearing" from further away
			var emission_box_size = remap(current_angle, twilight_start_angle, night_start_angle, 10.0, 50.0)
			var particle_material = star_particles.process_material as ParticleProcessMaterial
			particle_material.emission_box_extents = Vector3(emission_box_size, 5.0, emission_box_size)
	# Calculate color based on which phase we're in
	if current_angle <= sunset_start_angle:
		# Full day
		fog_density = 0.0
		sky_color = day_sky_color
		horizon_color = day_horizon_color
		light_energy = sunlight_daytime
	elif current_angle <= twilight_start_angle:
		# Sunset transition
		var factor = inverse_lerp(sunset_start_angle, twilight_start_angle, current_angle)
		sky_color = day_sky_color.lerp(sunset_sky_color, factor)
		horizon_color = day_horizon_color.lerp(sunset_horizon_color, factor)
		light_energy = lerp(sunlight_daytime, sunlight_sunset, factor)
	elif current_angle <= night_start_angle:
		# Twilight transition
		var factor = inverse_lerp(twilight_start_angle, night_start_angle, current_angle)
		sky_color = sunset_sky_color.lerp(twilight_sky_color, factor)
		horizon_color = sunset_horizon_color.lerp(twilight_horizon_color, factor)
		light_energy = lerp(sunlight_sunset, sunlight_twilight, factor)
	else:
		# Check if we're in deep night (well below horizon)
		if current_angle >= 60.0:  # Deep night threshold
			sky_color = night_sky_color
			horizon_color = night_horizon_color
		else:
			# Transition to full night
			var factor = inverse_lerp(night_start_angle, 60.0, current_angle)
			sky_color = twilight_sky_color.lerp(night_sky_color, factor)
			horizon_color = twilight_horizon_color.lerp(night_horizon_color, factor)
			light_energy = lerp(sunlight_twilight, sunlight_night, factor)
	
	# Apply our calculated colors
	environment.sky.sky_material.set_sky_top_color(sky_color)
	environment.sky.sky_material.set_sky_horizon_color(horizon_color)
	environment.fog_density = fog_density
	var time = deg_to_rad(0.05)
	rotate_x(time)


#func calculate_transition_factor(angle: float) -> float:
	# Define our transition range (how many degrees to transition over)
#	var transition_range = 20.0
	
	# Calculate where we are in the transition
#	var transition_start = transition_angle + transition_range
#	var transition_end = transition_angle
	
	# Create a smooth transition between 0 and 1
#	return clamp(inverse_lerp(transition_start, transition_end, angle), 0.0, 1.0)
