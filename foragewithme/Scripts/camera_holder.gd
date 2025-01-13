extends SpringArm3D

@onready var camera: Camera3D = $Camera3D

# Camera constraints for vertical rotation
const VERTICAL_LOW = deg_to_rad(-45)   # Maximum look-up angle
const VERTICAL_HIGH = deg_to_rad(60)   # Maximum look-down angle
const MOUSE_SENSITIVITY = 0.04

# Camera states
var is_orbiting: bool = false
var is_transitioning: bool = false
var vertical_rotation: float = 0.0

# Transition state
var transition_weight: float = 0.0
var start_transform: Transform3D
var target_y_rotation: float = 0.0

# Spring arm configuration
const ARM_HEIGHT = 1.0
const ARM_LENGTH = 4.0
const INITIAL_Y_ROTATION = deg_to_rad(-90)  # Camera starts behind player (-90 degrees)

# Transition settings
const TRANSITION_DURATION = 0.5
const TRANSITION_EASE = Tween.EASE_OUT
const TRANSITION_TRANS = Tween.TRANS_CUBIC

func _ready():
	# Set up spring arm properties
	spring_length = ARM_LENGTH
	margin = 0.25
	shape = create_shape()
	collision_mask = 1
	
	# Set initial position and rotation
	position = Vector3(0, ARM_HEIGHT, 0)
	rotation.y = INITIAL_Y_ROTATION
	vertical_rotation = 0.0

func create_shape() -> Shape3D:
	var shape = SphereShape3D.new()
	shape.radius = 0.25
	return shape

# Normalize angle to find shortest rotation path
func normalize_angle(angle: float) -> float:
	angle = fmod(angle, PI * 2.0)
	if angle > PI:
		angle -= PI * 2.0
	elif angle < -PI:
		angle += PI * 2.0
	return angle

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and !is_transitioning:
			start_orbit()
		elif !event.pressed and is_orbiting:
			end_orbit()
	
	# Only handle mouse motion if we're not transitioning
	if event is InputEventMouseMotion and !is_transitioning:
		handle_mouse_motion(event)

func handle_mouse_motion(event: InputEventMouseMotion):
	# Always handle vertical rotation
	var delta_vertical = deg_to_rad(event.relative.y * -MOUSE_SENSITIVITY)
	vertical_rotation = clamp(
		vertical_rotation + delta_vertical,
		VERTICAL_LOW,
		VERTICAL_HIGH
	)
	rotation.x = vertical_rotation
	
	# Only handle horizontal rotation in orbit mode
	if is_orbiting:
		var delta_horizontal = deg_to_rad(event.relative.x * -MOUSE_SENSITIVITY)
		rotation.y += delta_horizontal

func start_orbit():
	is_orbiting = true
	is_transitioning = false

func end_orbit():
	if !is_orbiting:
		return
	
	# Store our current transform
	start_transform = transform
	
	# Calculate shortest path back to home position
	var current_y = normalize_angle(rotation.y)
	var target_y = normalize_angle(INITIAL_Y_ROTATION)
	var delta = normalize_angle(target_y - current_y)
	target_y_rotation = current_y + delta
	
	# Start transition
	is_transitioning = true
	is_orbiting = false
	transition_weight = 0.0
	
	var tween = create_tween()
	tween.set_trans(TRANSITION_TRANS)
	tween.set_ease(TRANSITION_EASE)
	
	# Smoothly interpolate the transition weight
	tween.tween_property(
		self,
		"transition_weight",
		1.0,
		TRANSITION_DURATION
	)
	
	# Clean up when transition completes
	tween.finished.connect(func():
		is_transitioning = false
		rotation.y = INITIAL_Y_ROTATION
	)

func _physics_process(_delta):
	if is_transitioning:
		# During transition, only interpolate the Y rotation
		rotation.y = lerp_angle(start_transform.basis.get_euler().y, target_y_rotation, transition_weight)
	elif !is_orbiting:
		# When not orbiting or transitioning, maintain home position
		rotation.y = INITIAL_Y_ROTATION
	
	# Always maintain correct height
	position.y = lerp(position.y, ARM_HEIGHT, 0.1)
